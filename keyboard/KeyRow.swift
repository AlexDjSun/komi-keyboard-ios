import UIKit

final class KeyRow: UIView {
    weak var delegate: KeyDelegate?
    var keys: [KeyBase] = []

    private let specialKeysLabels: Set<String> = [
        "123", "globe", "space", "return", "ABC", "#+=", "backspace", "shift"
    ]
    private var keyWeights: [CGFloat] = []

    init(
        keys labels: [String],
        delegate: KeyDelegate?,
        biggestRowLength: Int = 12,
        hints: [String: String] = [:],
        subkeys: [String: [String]] = [:]
    ) {
        self.delegate = delegate
        super.init(frame: .zero)

        keys = labels.map { label in
            if specialKeysLabels.contains(label) {
                return SpecialKey(keyLabel: label)
            }
            return CharacterKey(
                character: label,
                hint: hints[label] ?? "",
                subkeys: subkeys[label] ?? []
            )
        }

        configureWeights(biggestRowLength: biggestRowLength)
        setupRow()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func configureWeights(biggestRowLength: Int) {
        let isSpaceRow = keys.contains { $0.title(for: .normal) == "space" }
        if isSpaceRow {
            configureSpaceRowWeights(biggestRowLength: biggestRowLength)
            return
        }

        if keys.count <= 7 {
            keyWeights = Array(repeating: 1, count: keys.count)
            return
        }

        if keys.count == biggestRowLength {
            keyWeights = Array(repeating: 1, count: keys.count)
            return
        }

        keyWeights = keys.map(weightForNonSpaceKey)
        let remainingWeight = max(0, CGFloat(biggestRowLength) - keyWeights.reduce(0, +))
        guard remainingWeight > 0,
              let firstCharacterIndex = keys.firstIndex(where: { $0 is CharacterKey }),
              let lastCharacterIndex = keys.lastIndex(where: { $0 is CharacterKey }) else {
            return
        }

        let leadingSpacer = InvisibleKey()
        let trailingSpacer = InvisibleKey()
        let spacerWeight = remainingWeight / 2

        keys.insert(trailingSpacer, at: lastCharacterIndex + 1)
        keyWeights.insert(spacerWeight, at: lastCharacterIndex + 1)
        keys.insert(leadingSpacer, at: firstCharacterIndex)
        keyWeights.insert(spacerWeight, at: firstCharacterIndex)
    }

    private func configureSpaceRowWeights(biggestRowLength: Int) {
        if #available(iOSApplicationExtension 26.0, *) {
            configureIOS26SpaceRowWeights(biggestRowLength: biggestRowLength)
            return
        }

        let nonSpaceSpecialCount = keys.filter {
            $0 is SpecialKey &&
                $0.title(for: .normal) != "space" &&
                $0.title(for: .normal) != "return"
        }.count

        keyWeights = keys.map { key in
            switch key.title(for: .normal) {
            case "space":
                return 0
            case "return":
                return 2
            case "123" where nonSpaceSpecialCount == 1:
                return 2
            case "ABC" where nonSpaceSpecialCount == 1:
                return 2
            default:
                return key is SpecialKey ? 1.25 : 1
            }
        }

        guard let spaceIndex = keys.firstIndex(where: { $0.title(for: .normal) == "space" }) else {
            return
        }
        let occupiedWeight = keyWeights.reduce(0, +)
        keyWeights[spaceIndex] = max(1, CGFloat(biggestRowLength) - occupiedWeight)
    }

    @available(iOSApplicationExtension 26.0, *)
    private func configureIOS26SpaceRowWeights(biggestRowLength: Int) {
        keyWeights = keys.map { key in
            switch key.title(for: .normal) {
            case "space":
                return 0
            case "return":
                return 2.75
            default:
                return key is SpecialKey ? 1.375 : 1
            }
        }

        guard let spaceIndex = keys.firstIndex(where: { $0.title(for: .normal) == "space" }) else {
            return
        }
        let occupiedWeight = keyWeights.reduce(0, +)
        keyWeights[spaceIndex] = max(1, CGFloat(biggestRowLength) - occupiedWeight)
    }

    private func weightForNonSpaceKey(_ key: KeyBase) -> CGFloat {
        key is SpecialKey ? 1.25 : 1
    }

    private func setupRow() {
        guard !keys.isEmpty else { return }
        let totalWeight = keyWeights.reduce(0, +)

        for (index, key) in keys.enumerated() {
            addSubview(key)
            key.delegate = delegate
            key.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                key.topAnchor.constraint(equalTo: topAnchor),
                key.bottomAnchor.constraint(equalTo: bottomAnchor),
                key.widthAnchor.constraint(
                    equalTo: widthAnchor,
                    multiplier: keyWeights[index] / totalWeight
                ),
                key.leadingAnchor.constraint(
                    equalTo: index == 0 ? leadingAnchor : keys[index - 1].trailingAnchor
                )
            ])
        }

        keys.last?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
