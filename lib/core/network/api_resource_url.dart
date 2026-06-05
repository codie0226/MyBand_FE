import '../config/app_config.dart';

Uri resolveApiResourceUri(
  String url, {
  String apiBaseUrl = AppConfig.apiBaseUrl,
}) {
  final uri = Uri.parse(url);
  if (uri.hasScheme) return uri;
  return Uri.parse(apiBaseUrl).resolveUri(uri);
}

bool isApiResourceUrl(String url, {String apiBaseUrl = AppConfig.apiBaseUrl}) {
  final uri = Uri.parse(url);
  if (!uri.hasScheme) return true;

  final base = Uri.parse(apiBaseUrl);
  return uri.scheme.toLowerCase() == base.scheme.toLowerCase() &&
      uri.host.toLowerCase() == base.host.toLowerCase() &&
      _effectivePort(uri) == _effectivePort(base);
}

Uri withQueryParameter(Uri uri, String key, String value) {
  return uri.replace(
    queryParameters: {
      ...uri.queryParameters,
      key: value,
    },
  );
}

String withAttachmentFilenameHint(String url, String filename) {
  final uri = Uri.parse(url);
  return withQueryParameter(uri, 'filename', filename).toString();
}

String? attachmentFilenameHint(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  final filename = uri.queryParameters['filename'];
  return filename == null || filename.trim().isEmpty ? null : filename;
}

int? _effectivePort(Uri uri) {
  if (uri.hasPort) return uri.port;
  return switch (uri.scheme.toLowerCase()) {
    'http' => 80,
    'https' => 443,
    _ => null,
  };
}
