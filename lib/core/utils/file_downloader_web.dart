import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../network/api_resource_url.dart';
import '../network/token_storage.dart';

Future<void> downloadFile(String url, {String? filename}) async {
  final shouldAuthenticate = isApiResourceUrl(url);
  final token = shouldAuthenticate
      ? await TokenStorage().readAccessToken()
      : null;
  final requestInit = _requestInit(token);
  final uri = resolveApiResourceUri(url);
  final response = requestInit == null
      ? await web.window.fetch(uri.toString().toJS).toDart
      : await web.window.fetch(uri.toString().toJS, requestInit).toDart;
  if (!response.ok) {
    throw StateError('Failed to download file: ${response.status}');
  }

  final blob = await response.blob().toDart;
  final objectUrl = web.URL.createObjectURL(blob);

  _triggerDownload(objectUrl, filename ?? _filenameFromUrl(url));
  web.URL.revokeObjectURL(objectUrl);
}

void _triggerDownload(String url, String filename) {
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = filename
    ..style.display = 'none';

  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}

String _filenameFromUrl(String url) {
  final pathSegments = Uri.tryParse(url)?.pathSegments;
  final lastSegment = pathSegments == null || pathSegments.isEmpty
      ? null
      : pathSegments.last;
  if (lastSegment == null || lastSegment.isEmpty) return 'download';
  return Uri.decodeComponent(lastSegment);
}

web.RequestInit? _requestInit(String? token) {
  if (token == null || token.isEmpty) return null;
  final headers = web.Headers();
  headers.set('Authorization', 'Bearer $token');
  return web.RequestInit(headers: headers);
}
