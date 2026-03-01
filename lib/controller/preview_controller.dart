import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class PreviewController extends GetxController {
  VideoPlayerController? videoPlayerController;
  FlickManager? flickManager;
  final AudioPlayer audioPlayer = AudioPlayer();

  var isInitialized = false.obs;
  var isAudio = false.obs;
  var isPlaying = false.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  // Track if user is currently dragging to prevent jumping
  bool isDragging = false;

  late String filePath;
  late String title;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args != null) {
      filePath = args['filePath'];
      title = args['title'];
      isAudio.value =
          filePath.toLowerCase().endsWith('.mp3') ||
          filePath.toLowerCase().endsWith('.m4a');
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      if (isAudio.value) {
        // Set release mode to loop or stop
        await audioPlayer.setReleaseMode(ReleaseMode.stop);

        // Listeners
        audioPlayer.onDurationChanged.listen((d) {
          if (d.inSeconds > 0) duration.value = d;
        });

        audioPlayer.onPositionChanged.listen((p) {
          if (!isDragging) position.value = p;
        });

        audioPlayer.onPlayerStateChanged.listen((state) {
          isPlaying.value = state == PlayerState.playing;
        });

        audioPlayer.onPlayerComplete.listen((_) {
          isPlaying.value = false;
          position.value = Duration.zero;
        });

        // Set source and wait for it to be ready
        await audioPlayer.setSource(DeviceFileSource(filePath));

        // Final check to get duration
        final d = await audioPlayer.getDuration();
        if (d != null) duration.value = d;

        await audioPlayer.resume();
      } else {
        videoPlayerController = VideoPlayerController.file(File(filePath));
        videoPlayerController!.addListener(_videoListener);
        flickManager = FlickManager(
          videoPlayerController: videoPlayerController!,
          autoPlay: true,
        );
      }
      isInitialized.value = true;
    } catch (e) {
      print("Error initializing player: $e");
    }
  }

  void _videoListener() {
    if (videoPlayerController != null &&
        videoPlayerController!.value.isInitialized) {
      if (!isDragging) {
        position.value = videoPlayerController!.value.position;
        duration.value = videoPlayerController!.value.duration;
      }
      isPlaying.value = videoPlayerController!.value.isPlaying;
    }
  }

  void togglePlayPause() {
    if (isAudio.value) {
      isPlaying.value ? audioPlayer.pause() : audioPlayer.resume();
    } else {
      if (videoPlayerController!.value.isPlaying) {
        flickManager?.flickControlManager?.pause();
      } else {
        flickManager?.flickControlManager?.play();
      }
    }
  }

  void seek(Duration pos) async {
    if (isAudio.value) {
      await audioPlayer.seek(pos);
    } else {
      await flickManager?.flickControlManager?.seekTo(pos);
    }
  }

  @override
  void onClose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    videoPlayerController?.removeListener(_videoListener);
    flickManager?.dispose();
    videoPlayerController?.dispose();
    audioPlayer.dispose();
    super.onClose();
  }
}
