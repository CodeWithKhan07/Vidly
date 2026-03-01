import 'package:fluttertoast/fluttertoast.dart';

class AppUtils {
  static void showToast({required String msg}) {
    Fluttertoast.showToast(msg: msg);
  }
}

enum LinkPlatform { youtube, instagram, tiktok, unknown, none }
// lib/core/utils/validators.dart

class VidlyValidators {
  // Robust regex for general URL structure
  static final RegExp _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    caseSensitive: false,
  );

  /// Validates the URL and returns an error message if invalid
  static String? validateVideoUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please paste a video link";
    }

    final url = value.trim().toLowerCase();

    if (!_urlRegex.hasMatch(url)) {
      return "Please enter a valid URL (starting with http/https)";
    }

    final platform = getPlatform(url);
    if (platform == LinkPlatform.unknown || platform == LinkPlatform.none) {
      return "Supported: YouTube, Instagram, and TikTok";
    }

    return null;
  }

  /// Identifies the platform from the URL
  static LinkPlatform getPlatform(String url) {
    final cleanUrl = url.trim().toLowerCase();

    if (cleanUrl.isEmpty) return LinkPlatform.none;

    // Check for YouTube patterns
    if (cleanUrl.contains('youtube.com') ||
        cleanUrl.contains('youtu.be') ||
        cleanUrl.contains('m.youtube.com')) {
      return LinkPlatform.youtube;
    }

    // Check for Instagram patterns
    if (cleanUrl.contains('instagram.com') || cleanUrl.contains('instagr.am')) {
      return LinkPlatform.instagram;
    }

    // Check for TikTok patterns
    if (cleanUrl.contains('tiktok.com')) {
      return LinkPlatform.tiktok;
    }

    return LinkPlatform.unknown;
  }
}
