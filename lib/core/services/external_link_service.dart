import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';

class ExternalLinkService {
  static Future<bool> launchWhatsApp({String? customMessage}) async {
    final baseUrl = AppConfig.whatsappLink;
    if (baseUrl.trim().isEmpty) {
      return false;
    }

    Uri uri = Uri.parse(baseUrl);
    if (customMessage != null && customMessage.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'text': customMessage,
      });
    }

    return launchUrlExternal(uri.toString());
  }

  static Future<bool> launchUrlExternal(String urlString) async {
    final uri = Uri.tryParse(urlString.trim());
    if (uri == null || !uri.hasAuthority) {
      return false;
    }

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      }
    } catch (_) {
      return false;
    }
  }
}
