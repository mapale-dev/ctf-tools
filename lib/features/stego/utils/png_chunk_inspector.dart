import 'dart:convert';
import 'dart:io';

/// PNG chunk 与元数据检查工具。
class PngChunkInspector {
  static PngInspectResult inspectHex(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toUpperCase();
    if (cleaned.length < 16) {
      throw const FormatException('PNG 数据至少需要 8 字节签名');
    }
    if (!cleaned.startsWith('89504E470D0A1A0A')) {
      throw const FormatException('不是有效的 PNG 签名');
    }

    final bytes = <int>[
      for (int i = 0; i < cleaned.length; i += 2)
        int.parse(cleaned.substring(i, i + 2), radix: 16),
    ];

    var offset = 8;
    final chunks = <PngChunkInfo>[];
    final notes = <String>[];
    var foundIend = false;

    while (offset + 12 <= bytes.length) {
      final length = _readUint32(bytes, offset);
      final typeBytes = bytes.sublist(offset + 4, offset + 8);
      final type = String.fromCharCodes(typeBytes);
      final dataStart = offset + 8;
      final dataEnd = dataStart + length;
      final crcEnd = dataEnd + 4;

      if (crcEnd > bytes.length) {
        notes.add('Chunk $type 长度超出输入边界，数据可能被截断');
        break;
      }

      final data = bytes.sublist(dataStart, dataEnd);
      chunks.add(PngChunkInfo(type: type, length: length));

      if (type == 'IHDR' && data.length >= 8) {
        final width = _readUint32(data, 0);
        final height = _readUint32(data, 4);
        notes.add('IHDR: ${width}x$height');
      }
      if (type == 'tEXt') {
        notes.add('tEXt: ${_decodeTextChunk(data)}');
      }
      if (type == 'zTXt') {
        notes.add(_decodeZtxtChunk(data));
      }
      if (type == 'iTXt') {
        notes.add(_decodeItxtChunk(data));
      }
      if (type == 'eXIf') {
        notes.add('eXIf: 检测到 EXIF 元数据');
      }
      if (type == 'IEND') {
        foundIend = true;
        if (crcEnd < bytes.length) {
          notes.add('IEND 后仍有 ${bytes.length - crcEnd} 字节尾随数据，存在隐藏载荷嫌疑');
        }
        break;
      }

      offset = crcEnd;
    }

    if (!foundIend) {
      notes.add('未找到 IEND，PNG 可能不完整');
    }

    return PngInspectResult(chunks: chunks, notes: notes);
  }

  static int _readUint32(List<int> bytes, int offset) {
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  static String _decodeLatin1(List<int> bytes) {
    return latin1.decode(bytes, allowInvalid: true);
  }

  static String _decodeTextChunk(List<int> data) {
    final separator = data.indexOf(0);
    if (separator <= 0) {
      return _decodeLatin1(data);
    }
    final keyword = _decodeLatin1(data.sublist(0, separator));
    final text = _decodeLatin1(data.sublist(separator + 1));
    return '$keyword = $text';
  }

  static String _decodeZtxtChunk(List<int> data) {
    final separator = data.indexOf(0);
    if (separator <= 0 || separator + 2 > data.length) {
      return 'zTXt: 格式无效';
    }
    final keyword = _decodeLatin1(data.sublist(0, separator));
    final compressionMethod = data[separator + 1];
    final compressedText = data.sublist(separator + 2);
    if (compressionMethod != 0) {
      return 'zTXt: $keyword (未知压缩方法 $compressionMethod)';
    }
    try {
      final text = _decodeLatin1(ZLibCodec().decode(compressedText));
      return 'zTXt: $keyword = $text';
    } catch (_) {
      return 'zTXt: $keyword (压缩文本解码失败)';
    }
  }

  static String _decodeItxtChunk(List<int> data) {
    final keywordEnd = data.indexOf(0);
    if (keywordEnd <= 0 || keywordEnd + 5 > data.length) {
      return 'iTXt: 格式无效';
    }

    final keyword = _decodeLatin1(data.sublist(0, keywordEnd));
    final compressionFlag = data[keywordEnd + 1];
    final compressionMethod = data[keywordEnd + 2];

    final languageEnd = data.indexOf(0, keywordEnd + 3);
    if (languageEnd < 0) {
      return 'iTXt: $keyword (缺少语言标签结束符)';
    }
    final translatedKeywordEnd = data.indexOf(0, languageEnd + 1);
    if (translatedKeywordEnd < 0) {
      return 'iTXt: $keyword (缺少翻译关键词结束符)';
    }

    final languageTag = _decodeLatin1(
      data.sublist(keywordEnd + 3, languageEnd),
    );
    final translatedKeyword = utf8.decode(
      data.sublist(languageEnd + 1, translatedKeywordEnd),
      allowMalformed: true,
    );
    final textBytes = data.sublist(translatedKeywordEnd + 1);

    try {
      final decodedBytes = compressionFlag == 1
          ? ZLibCodec().decode(textBytes)
          : textBytes;
      final text = utf8.decode(decodedBytes, allowMalformed: true);
      final metadata = <String>[
        if (languageTag.isNotEmpty) 'lang=$languageTag',
        if (translatedKeyword.isNotEmpty) 'translated=$translatedKeyword',
        'compressed=${compressionFlag == 1 ? 'yes' : 'no'}',
      ].join(', ');
      return metadata.isEmpty
          ? 'iTXt: $keyword = $text'
          : 'iTXt: $keyword = $text ($metadata)';
    } catch (_) {
      if (compressionFlag == 1) {
        return 'iTXt: $keyword (压缩国际化文本解码失败, method=$compressionMethod)';
      }
      return 'iTXt: $keyword (国际化文本解码失败)';
    }
  }
}

class PngInspectResult {
  const PngInspectResult({required this.chunks, required this.notes});

  final List<PngChunkInfo> chunks;
  final List<String> notes;
}

class PngChunkInfo {
  const PngChunkInfo({required this.type, required this.length});

  final String type;
  final int length;
}
