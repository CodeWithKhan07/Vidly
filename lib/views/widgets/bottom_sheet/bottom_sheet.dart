import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/bottom_sheet_controller.dart';
import '../../../data/models/media_model.dart';

class VidlyBottomSheet extends StatelessWidget {
  final MediaModel media;
  final Function(Medias) onDownload;

  const VidlyBottomSheet({
    super.key,
    required this.media,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize the controller specifically for this sheet instance
    final controller = Get.put(VidlyBottomSheetController(media));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22), // Dark background matching image_d905dd.png
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildPreview(),
            const SizedBox(height: 24),
            _buildSectionTitle("CHOOSE QUALITY"),
            const SizedBox(height: 12),
            _buildFormatList(controller),
            const SizedBox(height: 24),
            _buildDownloadButton(controller),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() => Container(
    width: 40,
    height: 4,
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(10),
    ),
  );

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        "Ready to download",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.close, color: Colors.white),
        style: IconButton.styleFrom(backgroundColor: Colors.white10),
      ),
    ],
  );

  Widget _buildPreview() => Stack(
    alignment: Alignment.bottomLeft,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          media.thumbnail ?? "",
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      Container(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Text(
          media.title ?? "Untitled",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );

  Widget _buildSectionTitle(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _buildFormatList(VidlyBottomSheetController controller) {
    return Obx(
      () => Column(
        children: List.generate(controller.filteredFormats.length, (index) {
          final item = controller.filteredFormats[index];
          final isSelected = controller.selectedIndex.value == index;
          final label = controller.mapQualityLabel(item);

          // UI Logic: 1080p, 720p formatting and removing dots
          final String extension = item.extension?.toUpperCase() ?? "MP4";
          final String resolution = _getResolution(label);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => controller.selectedIndex.value = index,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blueAccent.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.blueAccent : Colors.white10,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      label == "MP3 AUDIO" ? Icons.audiotrack : Icons.videocam,
                      color: isSelected ? Colors.blueAccent : Colors.white70,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "$extension $resolution", // No dots as requested
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? Colors.blueAccent : Colors.white24,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getResolution(String label) {
    if (label == "FULL HD") return "1080p";
    if (label == "HD") return "720p";
    if (label == "SD") return "480p";
    return "";
  }

  Widget _buildDownloadButton(VidlyBottomSheetController controller) =>
      SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(
              0xFF438AFE,
            ), // Specific blue from image_d905dd.png
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          onPressed: () {
            if (controller.filteredFormats.isNotEmpty) {
              onDownload(
                controller.filteredFormats[controller.selectedIndex.value],
              );
            }
            Get.back();
          },
          child: const Text(
            "Download Now",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
