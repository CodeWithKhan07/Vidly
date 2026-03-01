import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vidly/core/utils/app_utils.dart';

class PermissionService {
  /// Request all necessary permissions for the app to function
  static Future<bool> requestAllPermissions() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    List<Permission> permissionsToRequest = [];

    if (sdkInt >= 33) {
      // Android 13 and above
      permissionsToRequest.addAll([
        Permission.videos,
        Permission.photos,
        Permission.audio,
        Permission.notification, // Fixes the crash you encountered
      ]);
    } else if (sdkInt >= 30) {
      // Android 11 & 12
      permissionsToRequest.addAll([
        Permission.manageExternalStorage,
        Permission.storage,
      ]);
    } else {
      // Android 10 and below
      permissionsToRequest.add(Permission.storage);
    }

    // Execute requests
    Map<Permission, PermissionStatus> statuses = await permissionsToRequest
        .request();

    // Check if critical permissions were granted
    // Note: We check specifically for videos/storage.
    // Sometimes users deny 'audio' or 'photos' but the app can still function for videos.
    if (sdkInt >= 33) {
      return statuses[Permission.videos]?.isGranted ?? false;
    } else if (sdkInt >= 30) {
      return statuses[Permission.manageExternalStorage]?.isGranted ?? false;
    } else {
      return statuses[Permission.storage]?.isGranted ?? false;
    }
  }

  /// Check current permission status without prompting
  static Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      // For Android 13+, we primarily care about Video and Notifications
      bool hasVideo = await Permission.videos.isGranted;
      bool hasNotif = await Permission.notification.isGranted;
      return hasVideo && hasNotif;
    } else if (sdkInt >= 30) {
      return await Permission.manageExternalStorage.isGranted;
    } else {
      return await Permission.storage.isGranted;
    }
  }

  /// Specialized check for Notification permission
  static Future<bool> hasNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    return await Permission.notification.isGranted;
  }

  /// Force open settings if user permanently denied permissions
  static Future<void> openSettings() async {
    AppUtils.showToast(
      msg: "Please grant permissions to download and play media",
    );
    await openAppSettings();
  }
}
