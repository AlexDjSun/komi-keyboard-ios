import AudioToolbox
import UIKit

final class KeyboardViewController: UIInputViewController {
    private enum KeyboardMode {
        case main
        case punctuation
        case secondaryPunctuation
    }

    private let predictionEngine = PredictionEngine()
    private let toolbarView = ToolbarView()
    private var currentKeyboardMode: KeyboardMode = .main
    private var isLandscape = false
    private var isTransitioningOrientation = false

    @IBOutlet private var mainKeyboardView: KeyboardView!
    @IBOutlet private var punctuationKeyboardView: KeyboardView!
    @IBOutlet private var secondaryPunctuationKeyboardView: KeyboardView!

    private var keyboardHeightConstraint: NSLayoutConstraint?
    private var toolbarHeightConstraint: NSLayoutConstraint?
    private var deleteTimer: Timer?

    private(set) var isLayoutShifted = false
    private var isLayoutCapsLocked = false
    private var isMainKeyboard: Bool {
        currentKeyboardMode == .main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        initializeToolbarView()
        initializeKeyboardViews()
        handleAutoCapitalization()

        predictionEngine.loadModels { [weak self] in
            self?.updatePredictions()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLandscape = currentInterfaceIsLandscape()
        configureHeightConstraintIfNeeded()
        updateViewSize(isLandscape: isLandscape)
        showKeyboard(currentKeyboardMode)
        handleAutoCapitalization()
        updatePredictions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isTransitioningOrientation else { return }
        let currentLandscapeValue = currentInterfaceIsLandscape()
        if currentLandscapeValue != isLandscape {
            isLandscape = currentLandscapeValue
            updateViewSize(isLandscape: currentLandscapeValue)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopContinuousDelete()
        super.viewWillDisappear(animated)
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        handleAutoCapitalization()
        updatePredictions()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)

        let nextIsLandscape: Bool
        if size.width > view.bounds.width {
            nextIsLandscape = true
        } else if size.width < view.bounds.width {
            nextIsLandscape = false
        } else {
            nextIsLandscape = currentInterfaceIsLandscape()
        }
        isLandscape = nextIsLandscape
        isTransitioningOrientation = true

        coordinator.animate { _ in
            self.dismissKeyPopups(in: self.view)
            self.updateViewSize(isLandscape: nextIsLandscape)
            self.view.layoutIfNeeded()
        } completion: { _ in
            let actualOrientation = self.currentInterfaceIsLandscape()
            self.isLandscape = actualOrientation
            self.isTransitioningOrientation = false
            self.updateViewSize(isLandscape: actualOrientation)
            self.view.setNeedsLayout()
        }
    }

    func updatePredictions() {
        guard let context = textDocumentProxy.documentContextBeforeInput else {
            toolbarView.updateSuggestions([])
            return
        }

        toolbarView.updateSuggestions(predictionEngine.getPredictions(for: context))
    }

    func acceptSuggestion(_ suggestion: PredictionSuggestion) {
        guard let context = textDocumentProxy.documentContextBeforeInput else {
            return
        }

        switch suggestion.kind {
        case .completion:
            let currentWordLength = TextTokenization.currentWordLength(in: context)
            guard currentWordLength > 0 else { return }
            for _ in 0..<currentWordLength {
                textDocumentProxy.deleteBackward()
            }
            textDocumentProxy.insertText(suggestion.text + " ")

        case .nextWord:
            let needsLeadingSpace = context.last.map { !$0.isWhitespace } ?? false
            textDocumentProxy.insertText((needsLeadingSpace ? " " : "") + suggestion.text + " ")
        }

        handleAutoCapitalization()
        updatePredictions()
    }

    private func configureBackground() {
        // The keyboard host already supplies the viewport material. Any
        // additional fill or effect here makes the system background opaque.
        view.backgroundColor = .clear
        view.isOpaque = false
        inputView?.backgroundColor = .clear
        inputView?.isOpaque = false
    }

    private func initializeToolbarView() {
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.keyboardViewController = self
        view.addSubview(toolbarView)

        let heightConstraint = toolbarView.heightAnchor.constraint(equalToConstant: 45)
        toolbarHeightConstraint = heightConstraint
        NSLayoutConstraint.activate([
            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarView.topAnchor.constraint(equalTo: view.topAnchor),
            heightConstraint
        ])
    }

    private func initializeKeyboardViews() {
        let includeGlobeKey = needsInputModeSwitchKey
        mainKeyboardView = KeyboardView(
            layout: .main,
            delegate: self,
            includeGlobeKey: includeGlobeKey
        )
        punctuationKeyboardView = KeyboardView(
            layout: .punctuation,
            delegate: self,
            includeGlobeKey: includeGlobeKey
        )
        secondaryPunctuationKeyboardView = KeyboardView(
            layout: .secondaryPunctuation,
            delegate: self,
            includeGlobeKey: includeGlobeKey
        )

        [mainKeyboardView, punctuationKeyboardView, secondaryPunctuationKeyboardView].forEach {
            guard let keyboardView = $0 else { return }
            view.addSubview(keyboardView)
            constrainKeyboardView(keyboardView)
        }
        showKeyboard(.main)
    }

    private func constrainKeyboardView(_ keyboardView: KeyboardView) {
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func showKeyboard(_ mode: KeyboardMode) {
        currentKeyboardMode = mode
        mainKeyboardView?.isHidden = mode != .main
        punctuationKeyboardView?.isHidden = mode != .punctuation
        secondaryPunctuationKeyboardView?.isHidden = mode != .secondaryPunctuation
    }

    private func configureHeightConstraintIfNeeded() {
        guard keyboardHeightConstraint == nil else { return }
        let constraint = view.heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = .required
        constraint.isActive = true
        keyboardHeightConstraint = constraint
    }

    private func updateViewSize(isLandscape: Bool) {
        let keyboardHeight = Calculator.getKeyboardHeight(isLandscape: isLandscape)
        let toolbarHeight = Calculator.getToolbarHeight(isLandscape: isLandscape)
        toolbarHeightConstraint?.constant = toolbarHeight
        keyboardHeightConstraint?.constant = keyboardHeight + toolbarHeight
    }

    private func currentInterfaceIsLandscape() -> Bool {
        if let orientation = view.window?.windowScene?.interfaceOrientation,
           orientation != .unknown {
            return orientation.isLandscape
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            return traitCollection.verticalSizeClass == .compact
        }
        return UIScreen.main.bounds.width > UIScreen.main.bounds.height
    }

    private func dismissKeyPopups(in parentView: UIView) {
        parentView.subviews.forEach { subview in
            if subview is KeyPopup || subview is SubcharPopup {
                subview.removeFromSuperview()
            } else {
                dismissKeyPopups(in: subview)
            }
        }
    }

    private func switchToPunctuationKeyboard() {
        showKeyboard(.punctuation)
    }

    private func switchToMainKeyboard() {
        showKeyboard(.main)
    }

    private func switchToSecondaryPunctuationKeyboard() {
        showKeyboard(.secondaryPunctuation)
    }

    private func toggleShift(on: Bool) {
        isLayoutShifted = on
        mainKeyboardView?.rows.forEach { row in
            row.keys.forEach { key in
                if let characterKey = key as? CharacterKey {
                    let newCharacter = on
                        ? characterKey.character.uppercased()
                        : characterKey.character.lowercased()
                    characterKey.updateCharacter(newCharacter: newCharacter)
                }

                if key.title(for: .normal) == "shift" {
                    let imageName: String
                    if isLayoutCapsLocked {
                        imageName = "capslock.fill"
                    } else if on {
                        imageName = "shift.fill"
                    } else {
                        imageName = "shift"
                    }
                    key.setImage(UIImage(named: imageName), for: .normal)
                }
                key.setNeedsDisplay()
            }
        }
    }

    private func handleAutoCapitalization() {
        guard let context = textDocumentProxy.documentContextBeforeInput else {
            if !isLayoutShifted && !isLayoutCapsLocked {
                toggleShift(on: true)
            }
            return
        }

        let trimmedContext = context.trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldShift = trimmedContext.isEmpty ||
            context.last == "\n" ||
            context.hasSuffix(". ") ||
            context.hasSuffix("! ") ||
            context.hasSuffix("? ")

        if shouldShift {
            toggleShift(on: true)
        } else if isLayoutShifted && !isLayoutCapsLocked {
            toggleShift(on: false)
        }
    }

    private func handleDoubleTapSpace() {
        let context = textDocumentProxy.documentContextBeforeInput
        if context?.suffix(2) != "  " {
            let punctuationMarks: Set<Character> = [".", "!", "?", ",", ":", ";", "-"]
            if context?.last == " " {
                let trimmedText = context?.trimmingCharacters(in: .whitespacesAndNewlines)
                if let lastCharacter = trimmedText?.last,
                   !punctuationMarks.contains(lastCharacter) {
                    textDocumentProxy.deleteBackward()
                    textDocumentProxy.insertText(".")
                    if !isLayoutShifted {
                        toggleShift(on: true)
                    }
                }
            }
        }
        textDocumentProxy.insertText(" ")
    }
}

extension KeyboardViewController: KeyDelegate {
    func startContinuousDelete() {
        stopContinuousDelete()
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self,
                  let context = self.textDocumentProxy.documentContextBeforeInput,
                  !context.isEmpty else {
                self?.stopContinuousDelete()
                return
            }
            self.textDocumentProxy.deleteBackward()
            AudioServicesPlaySystemSound(1155)
        }
        deleteTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stopContinuousDelete() {
        deleteTimer?.invalidate()
        deleteTimer = nil
    }

    func isShifted() -> Bool {
        isLayoutShifted
    }

    func keyDidTap(character: String) {
        switch character {
        case "backspace":
            textDocumentProxy.deleteBackward()
            handleAutoCapitalization()

        case "space":
            textDocumentProxy.insertText(" ")
            if !isMainKeyboard {
                switchToMainKeyboard()
            }
            handleAutoCapitalization()

        case "return":
            textDocumentProxy.insertText("\n")
            handleAutoCapitalization()

        case "globe":
            break

        case "shift":
            isLayoutCapsLocked = false
            toggleShift(on: !isLayoutShifted)

        case "123":
            switchToPunctuationKeyboard()

        case "ABC":
            switchToMainKeyboard()

        case "#+=":
            switchToSecondaryPunctuationKeyboard()

        default:
            let needsCaseAdjustment = character.count > 1 &&
                isLayoutShifted &&
                !isLayoutCapsLocked
            let insertedCharacter = needsCaseAdjustment
                ? String(character.prefix(1) + character.dropFirst().lowercased())
                : character
            textDocumentProxy.insertText(insertedCharacter)
            if isLayoutShifted && !isLayoutCapsLocked {
                toggleShift(on: false)
            }
            handleAutoCapitalization()
        }
        updatePredictions()
    }

    func handleCursorMove(cursorMovement: Int) {
        textDocumentProxy.adjustTextPosition(byCharacterOffset: cursorMovement)
    }

    func setGlobeKeySelector(globeKey: SpecialKey) {
        globeKey.addTarget(
            self,
            action: #selector(handleInputModeList(from:with:)),
            for: .allTouchEvents
        )
    }

    func handleDoubleTap(character: String) {
        switch character {
        case "backspace":
            textDocumentProxy.deleteBackward()
            handleAutoCapitalization()

        case "space":
            handleDoubleTapSpace()

        case "return":
            textDocumentProxy.insertText("\n")

        case "shift":
            isLayoutCapsLocked = true
            toggleShift(on: true)

        default:
            break
        }
        updatePredictions()
    }
}
