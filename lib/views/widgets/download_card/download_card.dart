import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../controller/download_controller.dart';
import '../../../data/models/download_model.dart';
import '../../preview/preview_screen.dart';

class DownloadMediaCard extends StatelessWidget {
  final DownloadTaskModel task;

  const DownloadMediaCard({super.key, required this.task});

  void _playMedia() {
    if (task.status == DownloadStatus.completed) {
      Get.to(
        () => const PreviewScreen(),
        arguments: {'filePath': task.savedPath, 'title': task.title},
      );
    } else if (task.status == DownloadStatus.failed) {
      Get.snackbar(
        "Download Failed",
        "Please retry the download",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Downloading",
        "Please wait for the download to finish",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black54,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildThumbnail() {
    bool hasLocalThumb =
        task.thumbnailPath.isNotEmpty && File(task.thumbnailPath).existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 50,
        height: 50,
        child: hasLocalThumb
            ? Image.file(
                File(task.thumbnailPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildErrorPlaceholder(),
              )
            : Image.network(
                task.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildErrorPlaceholder(),
              ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.white10,
      child: const Icon(Icons.play_arrow, color: Colors.white24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DownloadController>();
    final isCompleted = task.status == DownloadStatus.completed;
    final isFailed = task.status == DownloadStatus.failed;

    final subtitle =
        "Video ${task.videoQuality ?? ''} ${task.extension.toUpperCase()}"
            .trim();

    return InkWell(
      onTap: _playMedia,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFailed
                ? Colors.redAccent.withOpacity(0.2)
                : Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildThumbnail(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted
                            ? subtitle
                            : isFailed
                            ? "Download Failed"
                            : "$subtitle • ${task.downloadedSize} / ${task.totalSize}",
                        style: TextStyle(
                          color: isFailed ? Colors.redAccent : Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons Logic
                if (isCompleted)
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white54,
                      size: 20,
                    ),
                    color: const Color(0xFF1C2128),
                    onSelected: (value) async {
                      if (value == 'play') _playMedia();
                      if (value == 'share')
                        await Share.shareXFiles([
                          XFile(task.savedPath),
                        ], text: task.title);
                      if (value == 'delete') controller.deleteTask(task);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'play',
                        child: _MenuRow(Icons.play_arrow, "Play"),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: _MenuRow(Icons.share, "Share"),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: _MenuRow(
                          Icons.delete_outline,
                          "Delete",
                          isDestructive: true,
                        ),
                      ),
                    ],
                  )
                else if (isFailed)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.blueAccent,
                          size: 22,
                        ),
                        onPressed: () => controller.retryDownload(task),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white54,
                          size: 20,
                        ),
                        onPressed: () => controller.deleteTask(task),
                      ),
                    ],
                  )
                else
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: () => controller.cancelDownload(task.id),
                  ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: isFailed ? 1.0 : task.progress,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isFailed
                              ? Colors.redAccent.withOpacity(0.5)
                              : Colors.blueAccent,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isFailed ? "Error" : "${(task.progress * 100).toInt()}%",
                    style: TextStyle(
                      color: isFailed ? Colors.redAccent : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Helper widget for clean menu items
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDestructive;

  const _MenuRow(this.icon, this.text, {this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDestructive ? Colors.redAccent : Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : Colors.white,
          ),
        ),
      ],
    );
  }
}
