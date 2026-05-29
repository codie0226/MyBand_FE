import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'api_providers.dart';
import '../utils/file_signature.dart';

enum AttachmentUploadType { image, file, auto }

class AttachmentRepository {
  final ApiClient _api;

  AttachmentRepository(this._api);

  Future<String> upload({
    required List<int> bytes,
    required String filename,
    AttachmentUploadType type = AttachmentUploadType.auto,
  }) async {
    final verified = validateSafeUploadFile(
      bytes: bytes,
      filename: filename,
      allowImages: type != AttachmentUploadType.file,
      allowPdf: type != AttachmentUploadType.image,
    );
    final endpoint = verified.kind == SafeUploadKind.pdf
        ? '/attachments/files'
        : '/attachments/images';
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(verified.mimeType),
      ),
    });

    final res = await _api.dio.post<Map<String, dynamic>>(
      endpoint,
      data: formData,
    );
    return res.data!['url'] as String;
  }
}

final attachmentRepositoryProvider = Provider<AttachmentRepository>((ref) {
  return AttachmentRepository(ref.watch(apiClientProvider));
});
