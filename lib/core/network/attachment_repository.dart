import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'api_providers.dart';

enum AttachmentUploadType { image, file, auto }

class AttachmentRepository {
  final ApiClient _api;

  AttachmentRepository(this._api);

  Future<String> upload({
    required List<int> bytes,
    required String filename,
    AttachmentUploadType type = AttachmentUploadType.auto,
  }) async {
    final resolvedType = type == AttachmentUploadType.auto
        ? _typeFromFilename(filename)
        : type;
    final endpoint = resolvedType == AttachmentUploadType.file
        ? '/attachments/files'
        : '/attachments/images';
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(_mimeTypeFor(filename, resolvedType)),
      ),
    });

    final res = await _api.dio.post<Map<String, dynamic>>(
      endpoint,
      data: formData,
    );
    return res.data!['url'] as String;
  }

  AttachmentUploadType _typeFromFilename(String filename) {
    return _extensionOf(filename) == '.pdf'
        ? AttachmentUploadType.file
        : AttachmentUploadType.image;
  }

  String _mimeTypeFor(String filename, AttachmentUploadType type) {
    final ext = _extensionOf(filename);
    if (type == AttachmentUploadType.file || ext == '.pdf') {
      return 'application/pdf';
    }

    return switch (ext) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.gif' => 'image/gif',
      '.webp' => 'image/webp',
      '.bmp' => 'image/bmp',
      '.svg' => 'image/svg+xml',
      '.tiff' || '.tif' => 'image/tiff',
      '.heic' => 'image/heic',
      '.heif' => 'image/heif',
      '.avif' => 'image/avif',
      _ => 'image/jpeg',
    };
  }

  String _extensionOf(String filename) {
    final dot = filename.lastIndexOf('.');
    return dot >= 0 ? filename.substring(dot).toLowerCase() : '';
  }
}

final attachmentRepositoryProvider = Provider<AttachmentRepository>((ref) {
  return AttachmentRepository(ref.watch(apiClientProvider));
});
