import 'package:url_launcher/url_launcher.dart';

import '../network/api_resource_url.dart';

Future<void> downloadFile(String url, {String? filename}) async {
  final uri = resolveApiResourceUri(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
