import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> downloadFile(String url, {String? filename}) async {
  final response = await web.window.fetch(url.toJS).toDart;
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
