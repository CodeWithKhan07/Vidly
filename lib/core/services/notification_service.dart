import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../views/preview/preview_screen.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();
  bool _isInitialized = false;

  // Primary branding color from your UI
  final Color primaryColor = const Color(0xFF438AFE);

  Future<NotificationService> init() async {
    await _initializeNotifications();
    return this;
  }

  Future<void> _initializeNotifications() async {
    _isInitialized = await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'download_channel',
        channelName: 'Downloads',
        channelDescription: 'Notifications for file download progress',
        defaultColor: primaryColor,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        onlyAlertOnce: true, // Crucial to avoid sound spam during progress
      ),
    ], debug: true);

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    if (receivedAction.buttonKeyPressed == 'OPEN_FILE' ||
        receivedAction.channelKey == 'download_channel') {
      final String? filePath = receivedAction.payload?['path'];
      final String? fileName = receivedAction.payload?['title'];

      if (filePath != null && filePath.isNotEmpty) {
        Get.to(
          () => const PreviewScreen(),
          arguments: {
            'filePath': filePath,
            'title': fileName ?? "Downloaded Video",
          },
        );
      }
    }
  }

  // --- PUBLIC METHODS ---

  /// Shows immediate feedback when the user clicks download
  Future<void> showDownloadStarted({
    required int id,
    required String fileName,
    required String thumbnail,
  }) async {
    if (!_isInitialized ||
        !await AwesomeNotifications().isNotificationAllowed())
      return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'download_channel',
        title: 'Download Started',
        body: 'Initializing $fileName...',
        notificationLayout: NotificationLayout.ProgressBar,
        progress: 0,
        largeIcon: thumbnail, // Shows thumbnail on the right
        category: NotificationCategory.Progress,
        color: primaryColor,
        locked: true,
        autoDismissible: false,
      ),
    );
  }

  /// Updated with Thumbnail support and branding colors
  Future<void> showDownloadProgress({
    required int id,
    required String fileName,
    required int progress,
    required String thumbnail, // Pass the thumbnail URL/Path
  }) async {
    if (!_isInitialized ||
        !await AwesomeNotifications().isNotificationAllowed())
      return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'download_channel',
        title: 'Downloading $fileName',
        body: 'Progress: $progress%',
        notificationLayout: NotificationLayout.ProgressBar,
        progress: progress.toDouble(),
        largeIcon: thumbnail, // Thumbnail icon
        category: NotificationCategory.Progress,
        color: primaryColor,
        locked: true,
        autoDismissible: false,
        showWhen: false,
      ),
    );
  }

  Future<void> showDownloadComplete({
    required int id,
    required String fileName,
    required String thumbnail,
    String? filePath,
  }) async {
    if (!_isInitialized ||
        !await AwesomeNotifications().isNotificationAllowed())
      return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'download_channel',
        title: 'Download Finished ✅',
        body: fileName,
        // Expands to show the full thumbnail when completed
        notificationLayout: NotificationLayout.BigPicture,
        bigPicture: thumbnail,
        largeIcon: thumbnail,
        category: NotificationCategory.Navigation,
        color: primaryColor,
        payload: {'path': filePath ?? '', 'title': fileName},
        locked: false,
        autoDismissible: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN_FILE',
          label: 'Open File',
          actionType: ActionType.Default,
          color: primaryColor,
        ),
      ],
    );
  }

  Future<void> showDownloadFailed({
    required int id,
    required String fileName,
  }) async {
    if (!_isInitialized ||
        !await AwesomeNotifications().isNotificationAllowed())
      return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'download_channel',
        title: 'Download Failed ❌',
        body: 'Could not download $fileName',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Error,
        backgroundColor: Colors.red,
        color: Colors.white,
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().dismiss(id);
  }
}
