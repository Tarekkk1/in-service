import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformService {
  /// Get the current platform as a string
  static String getCurrentPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }

  /// Check if running on mobile platform
  static bool isMobile() {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  /// Check if running on desktop platform
  static bool isDesktop() {
    return !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  }

  /// Check if running on web
  static bool isWeb() {
    return kIsWeb;
  }

  /// Get platform display name
  static String getPlatformDisplayName() {
    final platform = getCurrentPlatform();
    switch (platform) {
      case 'web':
        return 'Web';
      case 'android':
        return 'Android';
      case 'ios':
        return 'iOS';
      case 'macos':
        return 'macOS';
      case 'windows':
        return 'Windows';
      case 'linux':
        return 'Linux';
      default:
        return 'Unknown';
    }
  }
}