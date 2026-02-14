import 'dart:convert';
import 'dart:typed_data';

import 'package:base_x/base_x.dart';

abstract class BaseCodec {
  String encode(List<int> bytes);
  List<int> decode(String text);
}

class BaseCodecFactory {
  static final Map<String, BaseCodec> _codecs = {
    "Base2": Base2Codec(),
    "Base8": Base8Codec(),
    "Base16": Base16Codec(),
    "Base32": Base32Codec(),
    "Base36": Base36Codec(),
    "Base58": Base58Codec(),
    "Base62": Base62Codec(),
    "Base64": Base64Codec(),
    "Base66": Base66Codec(),
  };

  static String encode(String name, List<int> bytes){
    return _codecs[name]!.encode(bytes);
  }

  static List<int> decode(String name, String text){
    return _codecs[name]!.decode(text);
  }
}

class Base2Codec implements BaseCodec {
  @override
  String encode(List<int> bytes) {
    if (bytes.isEmpty) return '';
    return bytes.map((b) => (b & 0xFF).toRadixString(2).padLeft(8, '0')).join();
  }

  @override
  List<int> decode(String text) {
    text = text.replaceAll(RegExp(r'\s+'), '');
    if (text.isEmpty) return [];
    
    List<int> bytes = [];
    for (int i = 0; i < text.length; i += 8) {
      int end = (i + 8 < text.length) ? i + 8 : text.length;
      String chunk = text.substring(i, end);
      if (chunk.isNotEmpty) {
        bytes.add(int.parse(chunk.padRight(8, '0'), radix: 2));
      }
    }
    return bytes;
  }
}

class Base8Codec implements BaseCodec {
  static final _codec = BaseXCodec(
    '01234567',
  );

  @override
  String encode(List<int> bytes) => _codec.encode(Uint8List.fromList(bytes));

  @override
  List<int> decode(String text) => _codec.decode(text);
}

class Base16Codec implements BaseCodec {
  @override
  String encode(List<int> bytes) {
    if (bytes.isEmpty) return '';
    return bytes.map((b) => (b & 0xFF).toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  List<int> decode(String text) {
    text = text.toLowerCase().replaceAll(RegExp(r'[^0-9a-f]'), '');
    if (text.isEmpty) return [];
    
    List<int> bytes = [];
    for (int i = 0; i < text.length; i += 2) {
      int end = (i + 2 < text.length) ? i + 2 : text.length;
      String chunk = text.substring(i, end);
      if (chunk.isNotEmpty) {
        bytes.add(int.parse(chunk, radix: 16));
      }
    }
    return bytes;
  }
}

class Base32Codec implements BaseCodec {
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  @override
  String encode(List<int> bytes) {
    if (bytes.isEmpty) return '';

    int i = 0;
    int index = 0;
    int digit = 0;
    int currByte;
    int nextByte;
    StringBuffer result = StringBuffer();

    while (i < bytes.length) {
      currByte = bytes[i] & 255;

      if (index > 3) {
        if ((i + 1) < bytes.length) {
          nextByte = bytes[i + 1] & 255;
        } else {
          nextByte = 0;
        }

        digit = currByte & (0xFF >> index);
        index = (index + 5) % 8;
        digit <<= index;
        digit |= nextByte >> (8 - index);
        i++;
      } else {
        digit = (currByte >> (8 - (index + 5))) & 0x1F;
        index = (index + 5) % 8;
        if (index == 0) i++;
      }
      result.write(_alphabet[digit]);
    }

    // Padding
    int padding = (8 - (result.length % 8)) % 8;
    for (int j = 0; j < padding; j++) {
      result.write('=');
    }

    return result.toString();
  }

  @override
  List<int> decode(String text) {
    text = text.toUpperCase().replaceAll('=', '').replaceAll(RegExp(r'\s+'), '');
    if (text.isEmpty) return [];

    List<int> bytes = [];
    int index = 0;
    int digit = 0;
    int currByte = 0;

    for (int i = 0; i < text.length; i++) {
      digit = _alphabet.indexOf(text[i]);
      if (digit == -1) continue;

      if (index <= 3) {
        index = (index + 5) % 8;
        if (index == 0) {
          currByte |= digit;
          bytes.add(currByte);
          currByte = 0;
        } else {
          currByte |= digit << (8 - index);
        }
      } else {
        index = (index + 5) % 8;
        currByte |= digit >> index;
        bytes.add(currByte);
        currByte = (digit << (8 - index)) & 255;
      }
    }
    return bytes;
  }
}

class Base36Codec implements BaseCodec {
  static final _codec = BaseXCodec(
    '0123456789abcdefghijklmnopqrstuvwxyz',
  );

  @override
  String encode(List<int> bytes) => _codec.encode(Uint8List.fromList(bytes));

  @override
  List<int> decode(String text) => _codec.decode(text);
}

class Base58Codec implements BaseCodec {
  static final _codec = BaseXCodec(
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz',
  );

  @override
  String encode(List<int> bytes) => _codec.encode(Uint8List.fromList(bytes));

  @override
  List<int> decode(String text) => _codec.decode(text);
}

class Base62Codec implements BaseCodec {
  static final _codec = BaseXCodec(
    '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
  );

  @override
  String encode(List<int> bytes) => _codec.encode(Uint8List.fromList(bytes));

  @override
  List<int> decode(String text) => _codec.decode(text);
}

class Base64Codec implements BaseCodec{
  @override
  List<int> decode(String text) {
    return base64.decode(text);
  }

  @override
  String encode(List<int> bytes) {
    return base64.encode(bytes);
  }
}

class Base66Codec implements BaseCodec{
  static final _codec = BaseXCodec(
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~',
  );

  @override
  String encode(List<int> bytes) => _codec.encode(Uint8List.fromList(bytes));

  @override
  List<int> decode(String text) => _codec.decode(text);
}
