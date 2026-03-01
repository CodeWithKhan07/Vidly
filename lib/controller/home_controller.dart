import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:get/get.dart';
import 'package:vidly/controller/download_controller.dart';
import 'package:vidly/core/utils/app_utils.dart';
import 'package:vidly/views/widgets/bottom_sheet/bottom_sheet.dart';

import '../data/models/media_model.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;
  final videoData = Rxn<MediaModel>();

  final urlController = TextEditingController();
  final downloadController = Get.find<DownloadController>();

  late StreamSubscription _intentDataStreamSubscription;
  bool _isAnalyzing = false;

  @override
  void onReady() {
    super.onReady();
    _initSharingIntent();
  }

  void _initSharingIntent() {
    _intentDataStreamSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedFile> value) => _processSharedFiles(value),
          onError: (err) => debugPrint("Intent Error: $err"),
        );

    FlutterSharingIntent.instance.getInitialSharing().then((
      List<SharedFile> value,
    ) {
      _processSharedFiles(value);
    });
  }

  void _processSharedFiles(List<SharedFile> files) {
    if (files.isEmpty) return;
    for (var file in files) {
      if (file.value != null && file.value!.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleSharedText(file.value!);
        });
        break;
      }
    }
  }

  void _handleSharedText(String text) {
    final RegExp urlRegExp = RegExp(r"(https?:\/\/[^\s]+)");
    final match = urlRegExp.firstMatch(text);

    if (match != null) {
      String cleanUrl = match.group(0)!;
      urlController.text = cleanUrl;
      analyzeVideoUrl();
    }
  }

  Future<void> analyzeVideoUrl() async {
    final url = urlController.text.trim();
    if (url.isEmpty || _isAnalyzing) return;

    try {
      FocusManager.instance.primaryFocus?.unfocus();
      _isAnalyzing = true;
      isLoading.value = true;
      videoData.value = null;
      await downloadController.fetchVideoData(url);
      videoData.value = downloadController.videoData.value;
      if (videoData.value != null) {
        onAnalyzeSuccess(videoData.value!);
      }
    } catch (e) {
      AppUtils.showToast(msg: "Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
      _isAnalyzing = false;
    }
  }

  void onAnalyzeSuccess(MediaModel data) {
    if (Get.isBottomSheetOpen!) {
      return;
    }
    Get.bottomSheet(
      VidlyBottomSheet(
        media: data,
        onDownload: (selectedFormat) {
          downloadController.startDownload(data, selectedFormat);
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {
    _intentDataStreamSubscription.cancel();
    urlController.dispose();
    super.onClose();
  }
}
