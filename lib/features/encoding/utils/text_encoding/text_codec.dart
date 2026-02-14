abstract class TextCodec {
  String encode(String text);
  String decode(String text);
}

class TextCoderFactory {
  static final Map<String,TextCodec> _codecs = {
    "Unicode" : UnicodeCoder(),
    "URL" : UrlCoder(),
    "HTML" : HtmlCoder(),
    "Quoted Printable" : QuotedPrintableCoder(),
    "Morse Code" : MorseCodeCoder()
  };

  static String encode(String name, String text){
    return _codecs[name]!.encode(text);
  }

  static String decode(String name, String text){
    return _codecs[name]!.decode(text);
  }
}

class UnicodeCoder implements TextCodec {
  @override
  String decode(String text) {
    if (text.isEmpty) return "";
    // 正则匹配 \uXXXX 格式的 Unicode 编码
    RegExp unicodeRegex = RegExp(r'\\u([0-9a-fA-F]{4})');
    return text.replaceAllMapped(unicodeRegex, (match) {
      // 将 16 进制字符串转为整数，再转为字符
      int code = int.parse(match.group(1)!, radix: 16);
      return String.fromCharCode(code);
    });
  }

  @override
  String encode(String text) {
    if (text.isEmpty) return "";
    StringBuffer buffer = StringBuffer();
    for (int codeUnit in text.runes) {
      // 对非 ASCII 字符进行 Unicode 编码，ASCII 字符保持原样
      if (codeUnit > 127) {
        buffer.write("\\u${codeUnit.toRadixString(16).padLeft(4, '0')}");
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }
}

class UrlCoder implements TextCodec{
  @override
  String decode(String text) {
    if(text.isEmpty) return "";
    return Uri.decodeComponent(text);
  }

  @override
  String encode(String text) {
    if (text.isEmpty) return "";
    return Uri.encodeComponent(text);
  }
}

class HtmlCoder implements TextCodec{
  @override
  String decode(String text) {
    if (text.isEmpty) return "";
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  @override
  String encode(String text) {
    if (text.isEmpty) return "";
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}

class QuotedPrintableCoder implements TextCodec {
  @override
  String decode(String text) {
    if (text.isEmpty) return "";

    StringBuffer result = StringBuffer();
    int i = 0;

    while (i < text.length) {
      // 匹配 =XX 格式的编码字符（XX为16进制）
      if (text[i] == '=' && i + 2 < text.length) {
        String hex = text.substring(i + 1, i + 3);
        try {
          // 将16进制转为字符
          int code = int.parse(hex, radix: 16);
          result.writeCharCode(code);
          i += 3;
        } catch (e) {
          // 解析失败则保留原字符
          result.write(text[i]);
          i++;
        }
      }
      // 处理软换行（=+换行），直接跳过
      else if (text[i] == '=' && i + 1 < text.length && (text[i+1] == '\r' || text[i+1] == '\n')) {
        i += 2;
        // 兼容 \r\n 换行
        if (i < text.length && text[i] == '\n') i++;
      }
      // 普通字符直接保留
      else {
        result.write(text[i]);
        i++;
      }
    }

    return result.toString();
  }

  @override
  String encode(String text) {
    if (text.isEmpty) return "";

    StringBuffer result = StringBuffer();
    int lineLength = 0; // 控制每行不超过76个字符（QP标准）

    for (int codeUnit in text.runes) {
      // ASCII可打印字符（33-60, 62-126）直接保留
      if ((codeUnit >= 33 && codeUnit <= 60) || (codeUnit >= 62 && codeUnit <= 126)) {
        result.writeCharCode(codeUnit);
        lineLength++;
      }
      // 空格和等号需要特殊编码
      else if (codeUnit == 32) { // 空格
        result.write('=20');
        lineLength += 3;
      } else if (codeUnit == 61) { // 等号
        result.write('=3D');
        lineLength += 3;
      }
      // 其他字符转为 =XX 格式
      else {
        String hex = codeUnit.toRadixString(16).toUpperCase().padLeft(2, '0');
        result.write('=$hex');
        lineLength += 3;
      }

      // 每行超过76个字符时添加软换行（=+换行）
      if (lineLength >= 76) {
        result.write('=\r\n');
        lineLength = 0;
      }
    }

    return result.toString();
  }
}

class MorseCodeCoder implements TextCodec {
  // 摩尔斯电码映射表（标准国际摩尔斯码）
  final Map<String, String> _morseMap = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.',
    'F': '..-.', 'G': '--.', 'H': '....', 'I': '..', 'J': '.---',
    'K': '-.-', 'L': '.-..', 'M': '--', 'N': '-.', 'O': '---',
    'P': '.--.', 'Q': '--.-', 'R': '.-.', 'S': '...', 'T': '-',
    'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-', 'Y': '-.--',
    'Z': '--..', '0': '-----', '1': '.----', '2': '..---',
    '3': '...--', '4': '....-', '5': '.....', '6': '-....',
    '7': '--...', '8': '---..', '9': '----.', '.': '.-.-.-',
    ',': '--..--', '?': '..--..', '!': '-.-.--', '/': '-..-.',
    '(': '-.--.', ')': '-.--.-', '&': '.-...', ':': '---...',
    ';': '-.-.-.', '=': '-...-', '+': '.-.-.', '-': '-....-',
    '_': '..--.-', '"': '.-..-.', '\$': '...-..-', '@': '.--.-.',
    ' ': '/'
  };

  // 反向映射表（用于解码）
  late final Map<String, String> _reverseMorseMap;

  MorseCodeCoder() {
    // 初始化反向映射表
    _reverseMorseMap = {
      for (var entry in _morseMap.entries) entry.value: entry.key
    };
  }

  @override
  String decode(String text) {
    if (text.isEmpty) return "";

    StringBuffer result = StringBuffer();
    // 按空格分割字符，按 / 分割单词
    List<String> words = text.split('/');

    for (String word in words) {
      List<String> chars = word.trim().split(' ');
      for (String char in chars) {
        if (char.isNotEmpty) {
          // 查找对应字符，找不到则保留原码
          result.write(_reverseMorseMap[char] ?? char);
        }
      }
      // 单词之间添加空格
      result.write(' ');
    }

    // 去除末尾多余的空格
    return result.toString().trim();
  }

  @override
  String encode(String text) {
    if (text.isEmpty) return "";

    StringBuffer result = StringBuffer();
    // 转为大写（摩尔斯码不区分大小写）
    String upperText = text.toUpperCase();

    for (int i = 0; i < upperText.length; i++) {
      String char = upperText[i];
      // 查找摩尔斯码，找不到则保留原字符
      String morse = _morseMap[char] ?? char;
      result.write(morse);

      // 字符之间加空格，最后一个字符不加
      if (i < upperText.length - 1) {
        // 空格用 / 表示，不需要再加空格
        if (char != ' ') {
          result.write(' ');
        }
      }
    }

    return result.toString();
  }
}