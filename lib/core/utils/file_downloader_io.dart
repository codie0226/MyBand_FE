import 'package:url_launcher/url_launcher.dart';

Future<void> downloadFile(String url, {String? filename}) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
