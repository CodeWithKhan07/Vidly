import 'package:get/get.dart';

import '../../../data/models/media_model.dart';

class VidlyBottomSheetController extends GetxController {
  final MediaModel media;

  VidlyBottomSheetController(this.media);

  var selectedIndex = 0.obs;
  var filteredFormats = <Medias>[].obs;

  @override
  void onInit() {
    super.onInit();
    _prepareFormats();
  }

  void _prepareFormats() {
    final allMedias = media.medias ?? [];
    final Map<String, Medias> uniqueMap = {};

    for (var item in allMedias) {
      final label = mapQualityLabel(item);
      if (label == "UNKNOWN") continue;
      if (!uniqueMap.containsKey(label)) {
        uniqueMap[label] = item;
      } else {
        final currentExt = uniqueMap[label]!.extension?.toLowerCase();
        final newExt = item.extension?.toLowerCase();
        if ((label != "MP3 AUDIO" && newExt == "mp4" && currentExt != "mp4") ||
            (label == "MP3 AUDIO" && newExt == "mp3" && currentExt != "mp3")) {
          uniqueMap[label] = item;
        }
      }
    }

    var result = uniqueMap.values.toList();
    const qualityOrder = {'FULL HD': 0, 'HD': 1, 'SD': 2, 'MP3 AUDIO': 3};
    result.sort((a, b) {
      final aOrder = qualityOrder[mapQualityLabel(a)] ?? 99;
      final bOrder = qualityOrder[mapQualityLabel(b)] ?? 99;
      return aOrder.compareTo(bOrder);
    });

    filteredFormats.assignAll(result);
  }

  String mapQualityLabel(Medias item) {
    final q = item.quality?.toLowerCase() ?? "";
    final isVideo = item.videoAvailable ?? false;
    final isAudio = item.audioAvailable ?? false;
    final ext = item.extension?.toLowerCase() ?? "";

    if (ext == 'mp3' || (isAudio && !isVideo) || q.contains('kbps')) {
      return "MP3 AUDIO";
    }
    if (q.contains('1080') || q.contains('full hd')) return "FULL HD";
    if (q.contains('720') || q.contains('hd')) return "HD";
    if (q.contains('480') || q.contains('360') || isVideo) return "SD";

    return "UNKNOWN";
  }
}
