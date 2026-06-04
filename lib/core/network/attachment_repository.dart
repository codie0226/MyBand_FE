import 'dart:typed_data';

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

  Future<Uint8List> fetchBytes(String attachmentUrl) async {
    final res = await _api.dio.get<List<int>>(
      attachmentUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = res.data;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Attachment response was empty');
    }
    return Uint8List.fromList(bytes);
  }
}

final attachmentRepositoryProvider = Provider<AttachmentRepository>((ref) {
  return AttachmentRepository(ref.watch(apiClientProvider));
});
