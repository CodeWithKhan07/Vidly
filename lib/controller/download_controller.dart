import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vidly/core/utils/app_utils.dart';
import 'package:vidly/data/repository/video_repository.dart';

import '../core/services/notification_service.dart';
import '../data/models/download_model.dart';
import '../data/models/media_model.dart';

class DownloadController extends GetxController {
  final VideoRepository _repository = VideoRepository();
  final Dio _dio = Dio();
  final NotificationService _notificationService = NotificationService.to;

  late Box<DownloadTaskModel> _downloadBox;
  final downloads = <DownloadTaskModel>[].obs;
  final Map<String, CancelToken> _cancelTokens = {};
  var videoData = Rxn<MediaModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _downloadBox = Hive.box<DownloadTaskModel>('downloads');
    _loadDownloads();
    _notificationService.init();
  }

  Future<void> fetchVideoData(String url) async {
    try {
      isLoading.value = true;
      videoData.value = null;
      final result = await _repository.fetchVideoInfo(url);
      videoData.value = result;
    } catch (e) {
      AppUtils.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  int _getNotificationId(String taskId) {
    try {
      return int.parse(
        taskId.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 8),
      );
    } catch (e) {
      return taskId.hashCode.abs();
    }
  }

  Future<void> _loadDownloads() async {
    List<DownloadTaskModel> savedTasks = _downloadBox.values.toList();
    List<DownloadTaskModel> validatedTasks = [];
    for (var task in savedTasks) {
      if (task.status == DownloadStatus.completed) {
        if (task.savedPath.isNotEmpty && File(task.savedPath).existsSync()) {
          validatedTasks.add(task);
        } else {
          await _downloadBox.delete(task.id);
          _deleteOrphanThumbnail(task.thumbnailPath);
        }
      } else {
        validatedTasks.add(task);
      }
    }
    downloads.assignAll(validatedTasks.reversed.toList());
  }

  void _deleteOrphanThumbnail(String path) {
    if (path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) file.delete().catchError((e) => debugPrint(e));
    }
  }

  void retryDownload(DownloadTaskModel task) {
    final media = MediaModel(
      sid: task.id,
      title: task.title,
      thumbnail: task.thumbnail,
    );
    final format = Medias(
      url: task.url,
      extension: task.extension,
      quality: task.videoQuality,
    );
    startDownload(media, format);
  }

  Future<void> startDownload(MediaModel media, Medias format) async {
    final String taskId =
        media.sid ?? DateTime.now().millisecondsSinceEpoch.toString();
    final int notificationId = _getNotificationId(taskId);
    final String cleanTitle =
        media.title?.replaceAll(RegExp(r'[<>:"/\\|?*]'), '') ?? 'video';
    final String fileName =
        "${cleanTitle}_$taskId.${format.extension ?? 'mp4'}";

    String localThumbPath = "";
    if (media.thumbnail != null && media.thumbnail!.isNotEmpty) {
      try {
        localThumbPath = await _downloadThumbnail(media.thumbnail!, taskId);
      } catch (e) {
        debugPrint("Thumbnail Error: $e");
      }
    }

    DownloadTaskModel task = DownloadTaskModel(
      id: taskId,
      title: media.title ?? "Untitled",
      thumbnail: media.thumbnail ?? "",
      thumbnailPath: localThumbPath,
      url: format.url!,
      extension: format.extension ?? "mp4",
      videoQuality: format.quality,
      status: DownloadStatus.downloading,
      progress: 0.0,
    );
    _updateTaskState(task);

    try {
      _notificationService.showDownloadStarted(
        thumbnail: media.thumbnail.toString(),
        id: notificationId,
        fileName: fileName,
      );
      final String savePath = await _getDirectoryPath(fileName);
      final CancelToken cancelToken = CancelToken();
      _cancelTokens[taskId] = cancelToken;
      int lastProgress = -1;

      await _repository.downloadFile(
        url: format.url!,
        savePath: savePath,
        cancelToken: cancelToken,
        onProgress: (count, total) {
          if (total != -1) {
            double progress = count / total;
            int progressPercent = (progress * 100).toInt();
            _updateTaskState(
              task.copyWith(
                progress: progress,
                downloadedSize: _formatBytes(count),
                totalSize: _formatBytes(total),
              ),
            );
            _notificationService.showDownloadProgress(
              thumbnail: media.thumbnail.toString(),
              id: notificationId,
              fileName: task.title,
              progress: progressPercent,
            );
          }
        },
      );

      await _autoSaveToGallery(savePath);
      await _notificationService.showDownloadComplete(
        thumbnail: media.thumbnail.toString(),
        id: notificationId,
        fileName: task.title,
        filePath: savePath,
      );
      _updateTaskState(
        task.copyWith(
          progress: 1.0,
          status: DownloadStatus.completed,
          savedPath: savePath,
        ),
      );
    } catch (e) {
      _notificationService.cancelNotification(notificationId);
      if (!(e is DioException && e.type == DioExceptionType.cancel)) {
        _updateTaskState(
          task.copyWith(status: DownloadStatus.failed, progress: 0.0),
        );
        await _notificationService.showDownloadFailed(
          id: notificationId,
          fileName: task.title,
        );
        AppUtils.showToast(msg: "Download Failed");
      }
    } finally {
      _cancelTokens.remove(taskId);
    }
  }

  void cancelDownload(String taskId) {
    if (_cancelTokens.containsKey(taskId)) {
      _cancelTokens[taskId]!.cancel("User cancelled");
      _cancelTokens.remove(taskId);
      _notificationService.cancelNotification(_getNotificationId(taskId));
      final index = downloads.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _updateTaskState(
          downloads[index].copyWith(status: DownloadStatus.failed),
        );
      }
    }
  }

  void deleteTask(DownloadTaskModel task) async {
    cancelDownload(task.id);
    downloads.removeWhere((t) => t.id == task.id);
    await _downloadBox.delete(task.id);
    if (task.savedPath.isNotEmpty) {
      final file = File(task.savedPath);
      if (await file.exists()) await file.delete();
    }
    if (task.thumbnailPath.isNotEmpty) {
      final thumbFile = File(task.thumbnailPath);
      if (await thumbFile.exists()) await thumbFile.delete();
    }
  }

  Future<void> _autoSaveToGallery(String path) async {
    try {
      if (await Gal.hasAccess() || await Gal.requestAccess()) {
        await Gal.putVideo(path);
      }
    } catch (e) {
      debugPrint("Gallery Save Error: $e");
    }
  }

  Future<String> _downloadThumbnail(String url, String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final String thumbDir = p.join(directory.path, '.thumbnails');
    if (!await Directory(thumbDir).exists()) {
      await Directory(thumbDir).create(recursive: true);
    }
    final String filePath = p.join(thumbDir, "$id.jpg");
    await _dio.download(url, filePath);
    return filePath;
  }

  void _updateTaskState(DownloadTaskModel task) {
    int index = downloads.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      downloads[index] = task;
    } else {
      downloads.insert(0, task);
    }
    _downloadBox.put(task.id, task);
  }

  Future<String> _getDirectoryPath(String fileName) async {
    Directory? directory = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download/Vidly')
        : await getApplicationDocumentsDirectory();
    if (!await directory.exists()) await directory.create(recursive: true);
    return p.join(directory.path, fileName);
  }

  String _formatBytes(int bytes) =>
      "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
}
