import 'package:url_launcher/url_launcher.dart';

enum WhatsAppTarget {
  support,
  deposit,
  withdraw,
}

class ExternalLinkService {
  static String supportWhatsAppNumber = '8767467998';
  static String depositWhatsAppNumber = '8767467998';
  static String withdrawWhatsAppNumber = '8767467998';

  static void updateWhatsAppConfig({
    String? support,
    String? deposit,
    String? withdraw,
  }) {
    if (support != null && support.trim().isNotEmpty) {
      supportWhatsAppNumber = support.trim();
    }
    if (deposit != null && deposit.trim().isNotEmpty) {
      depositWhatsAppNumber = deposit.trim();
    }
    if (withdraw != null && withdraw.trim().isNotEmpty) {
      withdrawWhatsAppNumber = withdraw.trim();
    }
  }

  static Future<bool> launchWhatsApp({
    WhatsAppTarget target = WhatsAppTarget.support,
    String? customMessage,
    String? explicitNumber,
  }) async {
    String phoneNum = explicitNumber ?? '';
    if (phoneNum.isEmpty) {
      switch (target) {
        case WhatsAppTarget.deposit:
          phoneNum = depositWhatsAppNumber;
          break;
        case WhatsAppTarget.withdraw:
          phoneNum = withdrawWhatsAppNumber;
          break;
        case WhatsAppTarget.support:
          phoneNum = supportWhatsAppNumber;
          break;
      }
    }

    String cleanPhone = phoneNum.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.isEmpty) {
      cleanPhone = '8767467998';
    }

    final urlString = 'https://wa.me/91$cleanPhone';
    Uri uri = Uri.parse(urlString);
    if (customMessage != null && customMessage.isNotEmpty) {
      uri = uri.replace(queryParameters: {
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
