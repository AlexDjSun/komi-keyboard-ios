// KeyboardLayouts.swift

struct KeyboardLayouts {
    var keys: [[String]]
    var hints: [String:String] = [:]
    var subchars: [String:[String]] = [:]
    
    static let main = KeyboardLayouts(
//        keys: [
//            ["й", "ц", "у", "к", "е", "н", "г", "щ", "ъ", "з", "х",],
//            ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "э", "̄"],
//            ["shift", "я", "ч", "с", "м", "и", "т", "ь", "б", "ю", "backspace"],
//            ["123", "globe", "space", "return"]
//        ],
        keys: [
            ["й", "у", "к", "е", "ё", "н", "ӈ", "щ", "х"],
            ["ы", "в", "а", "п", "р", "о", "л", "ъ", "э"],
            ["shift", "я", "с", "м", "и", "т", "ь", "ю", "backspace"],
            ["123", "globe", "space", "return"]
        ],
        hints: [
            "а": "а̄",
            "щ": "ш",
            "е": "ё",
            "и": "ӣ",
            "о": "о̄",
            "з": "ж",
            "н": "ӈ",
            "у": "ӯ",
            "ы": "ы̄",
            "э": "э̄",
            "ю": "ю̄",
            "я": "я̄",
        ],
        subchars: [
            "а": ["а̄"],
            "е": ["ё", "е̄", "ё̄"],
            "и": ["ӣ", "й"],
            "й": ["ӣ"],
            "з": ["ж"],
            "н": ["ӈ"],
            "о": ["о̄"],
            "у": ["ӯ"],
            "щ": ["ш"],
            "э": ["э̄"],
            "ъ": ["ь"],
            "ы": ["ы̄"],
            "ь": ["ъ"],
            "ю": ["ю̄"],
            "я": ["я̄"]
        ]
    )
    
    static let punctuation = KeyboardLayouts(
        keys: [
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
            ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
            ["#+=", ".", ",", "?", "!", "\'", "backspace"],
            ["ABC", "globe", "space", "return"]
        ],
        subchars: [
            "1": ["1", "¹"],
            "2": ["2", "²"],
            "3": ["3", "³"],
            "4": ["4", "¼"],
            "5": ["5", "½"],
            "6": ["6", "¾"],
            "7": ["7", "⅞"],
            "8": ["8", "∞"],
            "9": ["9", "°"],
            "0": ["0", "º"],
            "-": ["-", "–", "—", "−", "_"],
            "/": ["/", "÷", "⁄"],
            ":": [":", "÷", "∶"],
            ";": [";", "⁏"],
            "(": ["(", "[", "{"],
            ")": [")", "]", "}"],
            "$": ["$", "€", "₽", "£", "¥", "₩"],
            "&": ["&", "№", "§", "¶", "†", "‡", "•", "◦"],
            "@": ["@", "№", "©", "®", "™", "℗", "℠", "℡", "№"],
            "\"": ["\"", "“", "”"],
            ".": [".", "…"],
            ",": [",", "‚", "„", "‛", "‟"],
            "?": ["?", "¿"],
            "!": ["!", "¡"],
            "\'": ["\'", "‘"],
        ])
    
    static let secondaryPunctuation = KeyboardLayouts(
        keys: [
            ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
            ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
            ["123", ".", ",", "?", "!", "\'", "backspace"],
            ["ABC", "globe", "space", "return"]
        ],
        subchars: [
            "{": ["{", "(", "["],
            "}": ["}", ")", "["],
            "#": ["#", "№"],
            "%": ["%", "‰"],
            "^": ["^", "↑", "↓", "↕"],
            "*": ["*", "×", "⋅", "∙"],
            "+": ["+", "±", "∓", "∔"],
            "=": ["=", "≠", "≡", "≢"],
            "_": ["_", "‾", "¯"],
            "\\": ["/", "|"],
            "|": ["|", "¦", "‖"],
            "~": ["~", "˜", "˜", "˜", "˜"],
            "<": ["<", "≤", "≲"],
            ">": [">", "≥", "≳"],
            "€": ["$", "€", "₽", "£", "¥", "₩"],
            "£": ["$", "€", "₽", "£", "¥", "₩"],
            "₽": ["$", "€", "₽", "£", "¥", "₩"],
            "•": ["•", "◦"],
            ".": [".", "…", "‥"],
            ",": [",", "‚", "„", "‛", "‟"],
            "?": ["?", "¿", "‽", "⁇", "⁈", "⁉"],
            "!": ["!", "¡", "‼", "⁉", "⁈", "⁇"],
            "\'": ["\'", "‘", "’", "‚", "‛", "‹", "›"],
        ])
}