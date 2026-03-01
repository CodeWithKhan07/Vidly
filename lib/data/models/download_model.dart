import 'package:hive/hive.dart';

part 'download_model.g.dart';

@HiveType(typeId: 0)
enum DownloadStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  downloading,
  @HiveField(2)
  paused,
  @HiveField(3)
  completed,
  @HiveField(4)
  failed,
}

@HiveType(typeId: 1)
class DownloadTaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String thumbnail; // This remains as the URL from the API

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String extension;

  @HiveField(5)
  final String? videoQuality;

  @HiveField(6)
  final double progress;

  @HiveField(7)
  final DownloadStatus status;

  @HiveField(8)
  final String savedPath;

  @HiveField(9)
  final String totalSize;

  @HiveField(10)
  final String downloadedSize;

  @HiveField(11)
  final String thumbnailPath; // NEW: The local path to the saved image file

  DownloadTaskModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.url,
    required this.extension,
    this.videoQuality,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.savedPath = "",
    this.totalSize = "",
    this.downloadedSize = "",
    this.thumbnailPath = "",
  });

  DownloadTaskModel copyWith({
    String? id,
    String? title,
    String? thumbnail,
    String? url,
    String? extension,
    String? videoQuality,
    double? progress,
    DownloadStatus? status,
    String? savedPath,
    String? totalSize,
    String? downloadedSize,
    String? thumbnailPath,
  }) {
    return DownloadTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      url: url ?? this.url,
      extension: extension ?? this.extension,
      videoQuality: videoQuality ?? this.videoQuality,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      savedPath: savedPath ?? this.savedPath,
      totalSize: totalSize ?? this.totalSize,
      downloadedSize: downloadedSize ?? this.downloadedSize,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
