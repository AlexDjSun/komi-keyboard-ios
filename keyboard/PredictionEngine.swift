import Foundation

enum PredictionKind {
    case completion
    case nextWord
}

struct PredictionSuggestion {
    let text: String
    let kind: PredictionKind
}

enum TextTokenization {
    static func isWordCharacter(_ character: Character) -> Bool {
        character.isLetter ||
            character.isNumber ||
            character == "-" ||
            character == "'" ||
            character == "’"
    }

    static func words(in text: String) -> [String] {
        text.split(whereSeparator: { !isWordCharacter($0) }).map(String.init)
    }

    static func currentWordLength(in text: String) -> Int {
        text.reversed().prefix(while: isWordCharacter).count
    }

    static func isTypingWord(in text: String) -> Bool {
        text.last.map(isWordCharacter) ?? false
    }
}

final class PredictionEngine {
    private struct RankedEntry {
        let key: String
        let suggestionRange: Range<Int>
    }

    private struct RankedIndex {
        static let empty = RankedIndex(entries: [], suggestions: [])

        let entries: [RankedEntry]
        let suggestions: [String]

        func values(for key: String, limit: Int) -> ArraySlice<String> {
            guard limit > 0, let entry = entry(for: key) else {
                return []
            }
            return suggestions[entry.suggestionRange].prefix(limit)
        }

        private func entry(for key: String) -> RankedEntry? {
            var lowerBound = 0
            var upperBound = entries.count

            while lowerBound < upperBound {
                let middle = lowerBound + (upperBound - lowerBound) / 2
                if entries[middle].key < key {
                    lowerBound = middle + 1
                } else {
                    upperBound = middle
                }
            }

            guard lowerBound < entries.count, entries[lowerBound].key == key else {
                return nil
            }
            return entries[lowerBound]
        }
    }

    private struct ScoredWord {
        let word: String
        let score: Float
    }

    private struct UnigramIndex {
        static let empty = UnigramIndex(words: [], globalSuggestions: [])

        let words: [ScoredWord]
        let globalSuggestions: [String]

        func prefixMatches(for prefix: String, limit: Int) -> [String] {
            guard limit > 0, !prefix.isEmpty else {
                return []
            }

            var lowerBound = 0
            var upperBound = words.count
            while lowerBound < upperBound {
                let middle = lowerBound + (upperBound - lowerBound) / 2
                if words[middle].word < prefix {
                    lowerBound = middle + 1
                } else {
                    upperBound = middle
                }
            }

            var bestMatches: [ScoredWord] = []
            var index = lowerBound
            while index < words.count, words[index].word.hasPrefix(prefix) {
                let candidate = words[index]
                if candidate.word != prefix {
                    let insertionIndex = bestMatches.firstIndex(where: { $0.score < candidate.score }) ?? bestMatches.endIndex
                    bestMatches.insert(candidate, at: insertionIndex)
                    if bestMatches.count > limit {
                        bestMatches.removeLast()
                    }
                }
                index += 1
            }
            return bestMatches.map(\.word)
        }
    }

    private struct CapitalizationEntry {
        let key: String
        let value: String
    }

    private struct CapitalizationIndex {
        static let empty = CapitalizationIndex(entries: [])

        let entries: [CapitalizationEntry]

        func value(for key: String) -> String? {
            var lowerBound = 0
            var upperBound = entries.count

            while lowerBound < upperBound {
                let middle = lowerBound + (upperBound - lowerBound) / 2
                if entries[middle].key < key {
                    lowerBound = middle + 1
                } else {
                    upperBound = middle
                }
            }

            guard lowerBound < entries.count, entries[lowerBound].key == key else {
                return nil
            }
            return entries[lowerBound].value
        }
    }

    private struct LoadedModels {
        let completions: RankedIndex
        let bigrams: RankedIndex
        let trigrams: RankedIndex
        let unigrams: UnigramIndex
        let capitalization: CapitalizationIndex
    }

    private enum ModelSection: String {
        case unigram
        case completion
        case bigram
        case trigram
        case capitalization
    }

    private let stateLock = NSLock()
    private var isLoading = false
    private var completionIndex = RankedIndex.empty
    private var bigramIndex = RankedIndex.empty
    private var trigramIndex = RankedIndex.empty
    private var unigramIndex = UnigramIndex.empty
    private var capitalizationIndex = CapitalizationIndex.empty

    func loadModels(completion: @escaping () -> Void) {
        stateLock.lock()
        guard !isLoading else {
            stateLock.unlock()
            return
        }
        isLoading = true
        stateLock.unlock()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let bundle = Bundle(for: type(of: self))

            if let models = Self.loadCompactModel(from: bundle) {
                self.store {
                    self.completionIndex = models.completions
                    self.bigramIndex = models.bigrams
                    self.trigramIndex = models.trigrams
                    self.unigramIndex = models.unigrams
                    self.capitalizationIndex = models.capitalization
                }
            }

            self.store { self.isLoading = false }
            DispatchQueue.main.async(execute: completion)
        }
    }

    func getPredictions(for context: String, maxSuggestions: Int = 3) -> [PredictionSuggestion] {
        guard maxSuggestions > 0 else {
            return []
        }

        let words = TextTokenization.words(in: context)
        let lowerWords = words.map { $0.lowercased() }
        let indexes = snapshot()

        if TextTokenization.isTypingWord(in: context),
           let currentWord = lowerWords.last,
           let originalWord = words.last {
            let startsWithUppercase = originalWord.first?.isUppercase == true
            let completions = indexes.completions.values(for: currentWord, limit: maxSuggestions)
            if !completions.isEmpty {
                return makeSuggestions(
                    from: completions,
                    kind: .completion,
                    startsWithUppercase: startsWithUppercase,
                    capitalization: indexes.capitalization
                )
            }

            let prefixMatches = indexes.unigrams.prefixMatches(for: currentWord, limit: maxSuggestions)
            if !prefixMatches.isEmpty {
                return makeSuggestions(
                    from: prefixMatches[...],
                    kind: .completion,
                    startsWithUppercase: startsWithUppercase,
                    capitalization: indexes.capitalization
                )
            }
        }

        if let lastWord = lowerWords.last {
            if lowerWords.count >= 2 {
                let previousWord = lowerWords[lowerWords.count - 2]
                let key = "\(previousWord) \(lastWord)"
                let predictions = indexes.trigrams.values(for: key, limit: maxSuggestions)
                if !predictions.isEmpty {
                    return makeSuggestions(
                        from: predictions,
                        kind: .nextWord,
                        startsWithUppercase: nil,
                        capitalization: indexes.capitalization
                    )
                }
            }

            let predictions = indexes.bigrams.values(for: lastWord, limit: maxSuggestions)
            if !predictions.isEmpty {
                return makeSuggestions(
                    from: predictions,
                    kind: .nextWord,
                    startsWithUppercase: nil,
                    capitalization: indexes.capitalization
                )
            }
        }

        return makeSuggestions(
            from: indexes.unigrams.globalSuggestions.prefix(maxSuggestions),
            kind: .nextWord,
            startsWithUppercase: nil,
            capitalization: indexes.capitalization
        )
    }

    private func makeSuggestions<S: Sequence>(
        from words: S,
        kind: PredictionKind,
        startsWithUppercase: Bool?,
        capitalization: CapitalizationIndex
    ) -> [PredictionSuggestion] where S.Element == String {
        words.map { word in
            PredictionSuggestion(
                text: formatted(
                    word: word,
                    startsWithUppercase: startsWithUppercase,
                    capitalization: capitalization
                ),
                kind: kind
            )
        }
    }

    private func formatted(
        word: String,
        startsWithUppercase: Bool?,
        capitalization: CapitalizationIndex
    ) -> String {
        let pattern = capitalization.value(for: word.lowercased()) ?? word
        if pattern.uppercased() == pattern, pattern.count >= 2 {
            return pattern
        }
        guard startsWithUppercase == true else {
            return pattern
        }
        return pattern.prefix(1).uppercased() + pattern.dropFirst()
    }

    private func store(_ mutation: () -> Void) {
        stateLock.lock()
        mutation()
        stateLock.unlock()
    }

    private func snapshot() -> (
        completions: RankedIndex,
        bigrams: RankedIndex,
        trigrams: RankedIndex,
        unigrams: UnigramIndex,
        capitalization: CapitalizationIndex
    ) {
        stateLock.lock()
        let result = (
            completionIndex,
            bigramIndex,
            trigramIndex,
            unigramIndex,
            capitalizationIndex
        )
        stateLock.unlock()
        return result
    }

    private static func loadCompactModel(from bundle: Bundle) -> LoadedModels? {
        guard let url = bundle.url(forResource: "prediction_model", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }

        var currentSection: ModelSection?
        var unigramWords: [ScoredWord] = []
        var completionEntries: [RankedEntry] = []
        var completionSuggestions: [String] = []
        var bigramEntries: [RankedEntry] = []
        var bigramSuggestions: [String] = []
        var trigramEntries: [RankedEntry] = []
        var trigramSuggestions: [String] = []
        var capitalizationEntries: [CapitalizationEntry] = []

        content.enumerateLines { line, _ in
            if line.first == "[", line.last == "]" {
                currentSection = ModelSection(rawValue: String(line.dropFirst().dropLast()))
                return
            }

            let fields = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard fields.count >= 2 else { return }
            let key = String(fields[0]).lowercased()

            switch currentSection {
            case .unigram:
                guard let score = Float(fields[1]) else { return }
                unigramWords.append(ScoredWord(word: key, score: score))

            case .completion:
                appendRankedEntry(
                    key: key,
                    fields: fields,
                    entries: &completionEntries,
                    suggestions: &completionSuggestions
                )

            case .bigram:
                appendRankedEntry(
                    key: key,
                    fields: fields,
                    entries: &bigramEntries,
                    suggestions: &bigramSuggestions
                )

            case .trigram:
                appendRankedEntry(
                    key: key,
                    fields: fields,
                    entries: &trigramEntries,
                    suggestions: &trigramSuggestions
                )

            case .capitalization:
                capitalizationEntries.append(
                    CapitalizationEntry(key: key, value: String(fields[1]))
                )

            case nil:
                break
            }
        }

        let globalSuggestions = unigramWords
            .sorted { $0.score > $1.score }
            .prefix(3)
            .map(\.word)

        return LoadedModels(
            completions: RankedIndex(
                entries: completionEntries,
                suggestions: completionSuggestions
            ),
            bigrams: RankedIndex(
                entries: bigramEntries,
                suggestions: bigramSuggestions
            ),
            trigrams: RankedIndex(
                entries: trigramEntries,
                suggestions: trigramSuggestions
            ),
            unigrams: UnigramIndex(
                words: unigramWords,
                globalSuggestions: globalSuggestions
            ),
            capitalization: CapitalizationIndex(entries: capitalizationEntries)
        )
    }

    private static func appendRankedEntry(
        key: String,
        fields: [Substring],
        entries: inout [RankedEntry],
        suggestions: inout [String]
    ) {
        let startIndex = suggestions.count
        suggestions.append(contentsOf: fields.dropFirst().map(String.init))
        entries.append(
            RankedEntry(
                key: key,
                suggestionRange: startIndex..<suggestions.count
            )
        )
    }
}
