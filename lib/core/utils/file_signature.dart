enum SafeUploadKind { image, pdf }

class SafeUploadFile {
  const SafeUploadFile({required this.kind, required this.mimeType});

  final SafeUploadKind kind;
  final String mimeType;
}

SafeUploadFile validateSafeUploadFile({
  required List<int> bytes,
  required String filename,
  bool allowImages = true,
  bool allowPdf = true,
}) {
  final detected = _detectFileType(bytes);
  if (detected == null) {
    throw const FormatException('허용된 이미지 또는 PDF 파일만 업로드할 수 있습니다.');
  }

  if (detected.kind == SafeUploadKind.image && !allowImages) {
    throw const FormatException('이미지 파일은 업로드할 수 없습니다.');
  }
  if (detected.kind == SafeUploadKind.pdf && !allowPdf) {
    throw const FormatException('PDF 파일만 업로드할 수 있습니다.');
  }

  final extension = _extensionOf(filename);
  final allowedExtensions = _extensionsByMime[detected.mimeType] ?? const [];
  if (!allowedExtensions.contains(extension)) {
    throw const FormatException('파일 확장자와 실제 형식이 일치하지 않습니다.');
  }

  return detected;
}

SafeUploadFile? _detectFileType(List<int> bytes) {
  if (_startsWith(bytes, const [0x25, 0x50, 0x44, 0x46, 0x2d])) {
    return const SafeUploadFile(
      kind: SafeUploadKind.pdf,
      mimeType: 'application/pdf',
    );
  }
  if (_startsWith(bytes, const [0xff, 0xd8, 0xff])) {
    return const SafeUploadFile(
      kind: SafeUploadKind.image,
      mimeType: 'image/jpeg',
    );
  }
  if (_startsWith(bytes, const [
    0x89,
    0x50,
    0x4e,
    0x47,
    0x0d,
    0x0a,
    0x1a,
    0x0a,
  ])) {
    return const SafeUploadFile(
      kind: SafeUploadKind.image,
      mimeType: 'image/png',
    );
  }
  if (_startsWith(bytes, const [0x47, 0x49, 0x46, 0x38, 0x37, 0x61]) ||
      _startsWith(bytes, const [0x47, 0x49, 0x46, 0x38, 0x39, 0x61])) {
    return const SafeUploadFile(
      kind: SafeUploadKind.image,
      mimeType: 'image/gif',
    );
  }
  if (bytes.length >= 12 &&
      _startsWith(bytes, const [0x52, 0x49, 0x46, 0x46]) &&
      _matchesAt(bytes, 8, const [0x57, 0x45, 0x42, 0x50])) {
    return const SafeUploadFile(
      kind: SafeUploadKind.image,
      mimeType: 'image/webp',
    );
  }
  if (bytes.length >= 12 &&
      _matchesAt(bytes, 4, const [0x66, 0x74, 0x79, 0x70])) {
    final brand = String.fromCharCodes(bytes.sublist(8, 12));
    if (brand == 'avif' || brand == 'avis') {
      return const SafeUploadFile(
        kind: SafeUploadKind.image,
        mimeType: 'image/avif',
      );
    }
    if (brand == 'heic' ||
        brand == 'heix' ||
        brand == 'hevc' ||
        brand == 'hevx') {
      return const SafeUploadFile(
        kind: SafeUploadKind.image,
        mimeType: 'image/heic',
      );
    }
    if (brand == 'mif1' || brand == 'msf1') {
      return const SafeUploadFile(
        kind: SafeUploadKind.image,
        mimeType: 'image/heif',
      );
    }
  }

  return null;
}

bool _startsWith(List<int> bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  return _matchesAt(bytes, 0, prefix);
}

bool _matchesAt(List<int> bytes, int offset, List<int> values) {
  if (bytes.length < offset + values.length) return false;
  for (var i = 0; i < values.length; i++) {
    if (bytes[offset + i] != values[i]) return false;
  }
  return true;
}

String _extensionOf(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot <= 0 || dot == filename.length - 1) return '';
  return filename.substring(dot).toLowerCase();
}

const _extensionsByMime = {
  'application/pdf': ['.pdf'],
  'image/jpeg': ['.jpg', '.jpeg'],
  'image/png': ['.png'],
  'image/gif': ['.gif'],
  'image/webp': ['.webp'],
  'image/heic': ['.heic'],
  'image/heif': ['.heif'],
  'image/avif': ['.avif'],
};
