import 'package:url_launcher/url_launcher.dart';

import '../network/api_resource_url.dart';
import '../network/token_storage.dart';

Future<void> downloadFile(String url, {String? filename}) async {
  var uri = resolveApiResourceUri(url);
  if (isApiResourceUrl(url)) {
    final token = await TokenStorage().readAccessToken();
    if (token != null && token.isNotEmpty) {
      uri = withQueryParameter(uri, 'token', token);
    }
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
