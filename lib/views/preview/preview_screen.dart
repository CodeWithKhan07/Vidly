import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/preview_controller.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PreviewController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2F80ED)),
          );
        }

        return Stack(
          children: [
            Positioned.fill(
              child: controller.isAudio.value
                  ? _buildAudioPlayer(controller)
                  : _buildFlickVideoPlayer(controller),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFlickVideoPlayer(PreviewController controller) {
    return FlickVideoPlayer(
      flickManager: controller.flickManager!,
      flickVideoWithControls: const FlickVideoWithControls(
        controls: FlickPortraitControls(),
        videoFit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAudioPlayer(PreviewController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Artwork
        Container(
          height: 240,
          width: 240,
          decoration: BoxDecoration(
            color: const Color(0xFF2F80ED).withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.music_note_rounded,
            size: 100,
            color: Color(0xFF2F80ED),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          controller.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ).paddingSymmetric(horizontal: 20),
        const SizedBox(height: 40),
        Obx(() {
          final double currentPos = controller.position.value.inSeconds
              .toDouble();
          final double totalDur = controller.duration.value.inSeconds
              .toDouble();
          double safeMax = totalDur > 0 ? totalDur : 1.0;
          double safeValue = currentPos.clamp(0.0, safeMax);

          return Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(Get.context!).copyWith(
                  activeTrackColor: const Color(0xFF2F80ED),
                  inactiveTrackColor: Colors.white10,
                  thumbColor: Colors.white,
                  trackHeight: 4,
                ),
                child: Slider(
                  value: safeValue,
                  max: safeMax,
                  min: 0.0,
                  onChangeStart: (value) {
                    controller.isDragging = true;
                  },
                  onChanged: (value) {
                    controller.position.value = Duration(
                      seconds: value.toInt(),
                    );
                  },
                  onChangeEnd: (value) {
                    controller.isDragging = false;
                    controller.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(controller.position.value),
                      style: const TextStyle(color: Colors.white38),
                    ),
                    Text(
                      _formatDuration(controller.duration.value),
                      style: const TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),

        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10, color: Colors.white, size: 30),
              onPressed: () => controller.seek(
                controller.position.value - const Duration(seconds: 10),
              ),
            ),
            const SizedBox(width: 20),
            Obx(
              () => IconButton(
                iconSize: 70,
                icon: Icon(
                  controller.isPlaying.value
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: const Color(0xFF2F80ED),
                ),
                onPressed: controller.togglePlayPause,
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.forward_10, color: Colors.white, size: 30),
              onPressed: () => controller.seek(
                controller.position.value + const Duration(seconds: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
