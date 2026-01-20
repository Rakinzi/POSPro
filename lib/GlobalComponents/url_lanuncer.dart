import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncher {
  static Future<void> handleLaunchURL(BuildContext context, String url, bool isEmail) async {
    try {
      final parsedUrl = Uri.tryParse(url);
      if (parsedUrl == null || !parsedUrl.hasScheme) {
        throw const FormatException('Invalid URL format');
      }

      final launched = await launchUrl(
        parsedUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch ${isEmail ? 'Email' : 'Sms'}')),
        );
      }
    } catch (e, stackTrace) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch the ${isEmail ? 'Email' : 'Sms'}')),
        );
      }
// Consider logging the error for debugging
      debugPrint('URL Launch Error: $e\n$stackTrace');
    }
  }
}
