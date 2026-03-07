import 'dart:convert';
import 'dart:io';

import 'package:ctf_tools/features/stego/utils/png_chunk_inspector.dart';
import 'package:ctf_tools/features/stego/utils/png_lsb_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PngChunkInspector', () {
    test('decodes zTXt and iTXt payloads', () {
      final pngHex = _buildPngHex([
        _chunk('IHDR', List<int>.filled(13, 0)),
        _chunk('zTXt', [
          ...latin1.encode('Comment'),
          0,
          0,
          ...ZLibCodec().encode(latin1.encode('flag{ztxt}')),
        ]),
        _chunk('iTXt', [
          ...latin1.encode('Comment'),
          0,
          1,
          0,
          ...latin1.encode('en-US'),
          0,
          ...utf8.encode('备注'),
          0,
          ...ZLibCodec().encode(utf8.encode('flag{iTXt}')),
        ]),
        _chunk('IEND', const []),
      ]);

      final result = PngChunkInspector.inspectHex(pngHex);

      expect(result.notes, contains('zTXt: Comment = flag{ztxt}'));
      expect(
        result.notes,
        contains(
          'iTXt: Comment = flag{iTXt} (lang=en-US, translated=备注, compressed=yes)',
        ),
      );
    });
  });

  group('PngLsbExtractor', () {
    test('extracts from higher bit planes', () {
      final pngHex = _buildPngHex([
        _chunk('IHDR', List<int>.filled(13, 0)),
        _chunk('IDAT', [0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04]),
        _chunk('IEND', const []),
      ]);

      final result = PngLsbExtractor.extract(pngHex, bitPlane: 2);

      expect(result.bitStream, '01000001');
      expect(result.textPreview, startsWith('A'));
      expect(result.notes, contains('Bit Plane: 2'));
    });

    test('rejects unsupported bit planes', () {
      expect(
        () => PngLsbExtractor.extract(
          '89504E470D0A1A0A0000000049454E4400000000',
          bitPlane: 8,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

String _buildPngHex(List<List<int>> chunks) {
  final bytes = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  for (final chunk in chunks) {
    bytes.addAll(chunk);
  }
  return bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();
}

List<int> _chunk(String type, List<int> data) {
  return [..._u32(data.length), ...latin1.encode(type), ...data, 0, 0, 0, 0];
}

List<int> _u32(int value) {
  return [
    (value >> 24) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 8) & 0xFF,
    value & 0xFF,
  ];
}
