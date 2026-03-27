import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Safely launches a URL on all platforms, including Android 11+.
/// Always uses [LaunchMode.externalApplication] for http/https URLs
/// so the system browser opens instead of a WebView.
Future<void> launchSafely(
  String url, {
  BuildContext? context,
}) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  final isWeb = uri.scheme == 'https' || uri.scheme == 'http';
  final mode =
      isWeb ? LaunchMode.externalApplication : LaunchMode.platformDefault;

  try {
    final launched = await launchUrl(uri, mode: mode);
    if (!launched && context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link.')),
      );
    }
  } catch (_) {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link.')),
      );
    }
  }
}
