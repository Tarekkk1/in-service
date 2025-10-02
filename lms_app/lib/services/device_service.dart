import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const String _deviceIdKey = 'device_id';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId != null) {
      return deviceId;
    }

    // Generate a new device ID if none exists
    deviceId = await _generateDeviceId();
    await prefs.setString(_deviceIdKey, deviceId);
    return deviceId;
  }

  static Future<String> _generateDeviceId() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      // Combine multiple identifiers for better uniqueness
      return '${androidInfo.id}_${androidInfo.brand}_${androidInfo.device}_${androidInfo.fingerprint}';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      // Use identifierForVendor which persists as long as the app is installed
      return iosInfo.identifierForVendor ?? 'unknown';
    }
    throw UnsupportedError('Unsupported platform');
  }
}