import 'package:flutter_test/flutter_test.dart';
import 'package:my_band/core/utils/file_signature.dart';

void main() {
  test('accepts PDF files with matching extension', () {
    final file = validateSafeUploadFile(
      bytes: '%PDF-1.7'.codeUnits,
      filename: 'score.pdf',
    );

    expect(file.kind, SafeUploadKind.pdf);
    expect(file.mimeType, 'application/pdf');
  });

  test('accepts PNG files with matching extension', () {
    final file = validateSafeUploadFile(
      bytes: const [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a],
      filename: 'sheet.png',
    );

    expect(file.kind, SafeUploadKind.image);
    expect(file.mimeType, 'image/png');
  });

  test('accepts AVIF files with matching extension', () {
    final file = validateSafeUploadFile(
      bytes: const [
        0x00,
        0x00,
        0x00,
        0x18,
        0x66,
        0x74,
        0x79,
        0x70,
        0x61,
        0x76,
        0x69,
        0x66,
      ],
      filename: 'cover.avif',
    );

    expect(file.kind, SafeUploadKind.image);
    expect(file.mimeType, 'image/avif');
  });

  test('rejects unknown file signatures', () {
    expect(
      () => validateSafeUploadFile(
        bytes: 'not really an image'.codeUnits,
        filename: 'payload.png',
      ),
      throwsFormatException,
    );
  });

  test('rejects extension and signature mismatch', () {
    expect(
      () => validateSafeUploadFile(
        bytes: '%PDF-1.7'.codeUnits,
        filename: 'payload.jpg',
      ),
      throwsFormatException,
    );
  });
}
