// KeyboardLayouts.swift

struct KeyboardLayouts {
    var keys: [[String]]
    var hints: [String:String] = [:]
    var subchars: [String:[String]] = [:]
    
    static let main = KeyboardLayouts(
        keys: [
            ["й", "ц", "у", "к", "е", "н", "г", "ш", "ъ", "з", "х",],
            ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"],
            ["shift", "я", "ч", "с", "м", "и", "т", "ь", "б", "ю", "backspace"],
            ["123", "globe", ".", "space", ",", "return"]
        ],
        hints: [
            "ш": "щ",
            "е": "ё",
            "и": "ӥ",
            "о": "ӧ",
            "з": "ӟ",
            "ж": "ӝ",
            "ч": "ӵ",
        ],
        subchars: [
            "а": ["ӓ", "а́"],
            "д": ["д́", "ԃ"],
            "е": ["ё", "е́"],
            "ж": ["ӝ", "җ"],
            "з": ["ӟ", "ԇ", "ҙ"],
            "и": ["ӥ", "и́", "і", "ӣ", "ј"],
            "й": ["ӥ", "ј"],
            "л": ["л̀", "ԉ"],
            "н": ["н̀", "ԋ"],
            "о": ["ӧ", "о́", "ө", "ӫ"],
            "ӧ": ["ӧ", "ә", "ӫ", "ө"],
            "с": ["с́", "ԍ"],
            "т": ["т́", "ԏ"],
            "у": ["ӱ", "у́", "ӯ"],
            "ч": ["ӵ", "ч̀"],
            "ш": ["щ"],
            "э": ["ӭ", "э́"],
            "ъ": ["ь", "ѣ"],
            "ы": ["ӹ", "ы́", "ы̆"],
            "ь": ["ъ", "ѣ"],
            "я": ["ѣ"]
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
