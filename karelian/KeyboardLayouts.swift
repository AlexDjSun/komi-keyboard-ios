// KeyboardLayouts.swift

struct KeyboardLayouts {
    var keys: [[String]]
    var hints: [String:String] = [:]
    var subchars: [String:[String]] = [:]
    
    static let main = KeyboardLayouts(
        keys: [
            ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
            ["a", "s", "d", "f", "g", "h", "j", "k", "l", "\'"],
            ["shift", "z", "x", "c", "v", "b", "n", "m", "backspace"],
            ["123", "globe", "ö", "space", ".", "return"]
        ],
        hints: [

            "t":"ť",
            "o":"ö",
            "u":"ü",

            "a":"ä",
            "s":"š",
            "d":"ď",
            "f":"ś",
            "h":"ž",
            "k":"ć",
            "l":"ľ",

            "z":"ź",
            "c":"ć",
            "v":"ź",
            "n":"ń",

            "ö":"õ"
        ],
        
        subchars: [

            "t": ["ť"],
            "o": ["ö", "õ"],
            "u": ["ü"],

            "a": ["ä", "å"],
            "s": ["š", "ś"],
            "d": ["ď"],
            "f": ["ś"],
            "h": ["ž"],
            "k": ["ć"],
            "l": ["ľ", "ł"],
            "\'": ["\'", "‘"],

            "z": ["ź", "ž"],
            "x": ["č"],
            "c": ["ć", "č"],
            "v": ["ź", "ž"],
            "n": ["ń", "ň"],
            
            "ö": ["õ", "ő", "ø", "œ"],
            ".": [",", "?", "!"]
        
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
