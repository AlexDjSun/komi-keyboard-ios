// KeyboardLayouts.swift

struct KeyboardLayouts {
    var keys: [[String]]
    var hints: [String:String] = [:]
    var subchars: [String:[String]] = [:]
    
    static let main = KeyboardLayouts(
        keys: [
            ["𐍙̇", "𐍣", "𐍚", "𐍔", "𐍝", "𐍒", "𐍥̇", "𐍗", "𐍥", "𐍕̇", "𐍖̇"],
            ["𐍯", "𐍮", "𐍐", "𐍟", "𐍠", "𐍞", "𐍛", "𐍓", "𐍕", "𐍖", "𐍔"],
            ["shift", "𐍩", "𐍤̇", "𐍡", "𐍜", "𐍙", "𐍢", "𐍤", "𐍑", "backspace"],
            ["123", ",", "globe", "space", ".", "return"]
        ],
        hints: [
            "𐍐": "а",
            "𐍑": "б",
            "𐍒": "г",
            "𐍓": "д",
            "𐍔": "э",
            "𐍕": "ж",
            "𐍖": "дж",
            "𐍗": "з",
            "𐍙": "и",
            "𐍚": "к",
            "𐍛": "л",
            "𐍜": "м",
            "𐍝": "н",
            "𐍞": "о",
            "𐍟": "п",
            "𐍠": "р",
            "𐍡": "с",
            "𐍢": "т",
            "𐍣": "у",
            "𐍤": "тш",
            "𐍥": "ш",
            "𐍯": "ы",
            "𐍮": "в",
            "𐍩": "ӧ",
            "𐍙̇": "й",
            "𐍤̇": "ч",
            "𐍕̇": "зь",
            "𐍥̇": "сь",
            "𐍖̇": "дз"
            
        ],
        
        subchars: [
            "𐍓": ["𐍓̇"],
            "𐍗": ["𐍕̇"],
            "𐍡": ["𐍥̇"],
            "𐍙": ["𐍙̇"],
            "𐍛": ["𐍛̇"],
            "𐍝": ["𐍝̇"],
            "𐍢": ["𐍢̇"],
            "𐍤": ["𐍤̇"],
            
        ])
    
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
