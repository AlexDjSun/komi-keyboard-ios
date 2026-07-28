import UIKit

class ToolbarView: UIView {
    
    private let hideKeyboardButton = UIButton(type: .custom)
    private var suggestionButtons: [UIButton] = []
    private var separatorViews: [UIView] = []
    private var suggestions: [PredictionSuggestion?] = Array(repeating: nil, count: 3)
    weak var keyboardViewController: KeyboardViewController? 

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureToolbar()
        setupSuggestionButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureToolbar() {
        setupHideKeyboardButton()
        configureLayout()
    }

    private func setupHideKeyboardButton() {
        let image = UIImage(named: "keyboard.down")?.withRenderingMode(.alwaysTemplate)
        hideKeyboardButton.setImage(image, for: .normal)
        hideKeyboardButton.setImage(image, for: .highlighted)
        hideKeyboardButton.tintColor = .dynamicTextColor
        hideKeyboardButton.backgroundColor = .clear
        hideKeyboardButton.adjustsImageWhenHighlighted = false
        hideKeyboardButton.accessibilityLabel = NSLocalizedString("Hide keyboard", comment: "")
        hideKeyboardButton.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
        hideKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hideKeyboardButton)
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            hideKeyboardButton.topAnchor.constraint(equalTo: topAnchor),
            hideKeyboardButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            hideKeyboardButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            hideKeyboardButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupSuggestionButtons() {
        for index in 0..<3 {
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitleColor(.dynamicTextColor, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(button)
            suggestionButtons.append(button)
        }
        
        for _ in 0..<2 {
            let separator = UIView()
            separator.backgroundColor = .separator
            separator.translatesAutoresizingMaskIntoConstraints = false
            addSubview(separator)
            separatorViews.append(separator)
        }
        
        let padding: CGFloat = 0
        
        for (index, button) in suggestionButtons.enumerated() {
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: topAnchor, constant: padding),
                button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
                button.heightAnchor.constraint(equalTo: heightAnchor, constant: -padding * 2)
            ])
            
            if index == 0 {
                button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding).isActive = true
            } else {
                button.leadingAnchor.constraint(equalTo: separatorViews[index - 1].trailingAnchor, constant: padding).isActive = true
                button.widthAnchor.constraint(equalTo: suggestionButtons[0].widthAnchor).isActive = true
            }
            
            if index < separatorViews.count {
                let separator = separatorViews[index]
                NSLayoutConstraint.activate([
                    separator.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: padding),
                    separator.centerYAnchor.constraint(equalTo: centerYAnchor),
                    separator.widthAnchor.constraint(equalToConstant: 1),
                    separator.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6)
                ])
            }
        }
        
        if let lastButton = suggestionButtons.last {
            lastButton.trailingAnchor.constraint(equalTo: hideKeyboardButton.leadingAnchor, constant: -padding).isActive = true
        }
    }

    @objc private func hideKeyboard() {
        keyboardViewController?.dismissKeyboard()
    }

    func setHideKeyboardButtonHidden(_ hidden: Bool) {
        hideKeyboardButton.isHidden = hidden
    }

    func updateSuggestions(_ suggestions: [PredictionSuggestion]) {
        for (index, button) in suggestionButtons.enumerated() {
            let suggestion = index < suggestions.count ? suggestions[index] : nil
            self.suggestions[index] = suggestion
            button.setTitle(suggestion?.text, for: .normal)
            button.isHidden = suggestion == nil
        }
    }

    @objc private func suggestionTapped(_ sender: UIButton) {
        guard suggestions.indices.contains(sender.tag),
              let suggestion = suggestions[sender.tag] else {
            return
        }
        keyboardViewController?.acceptSuggestion(suggestion)
    }
}
