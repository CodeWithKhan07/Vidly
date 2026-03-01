import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/download_controller.dart';
import '../../data/models/download_model.dart';
import '../widgets/download_card/download_card.dart';

class DownloadsScreen extends GetView<DownloadController> {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1117),
          elevation: 0,
          title: const Text(
            "Downloads",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.blueAccent,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Ongoing"),
                    Obx(() {
                      final count = controller.downloads
                          .where((t) => t.status != DownloadStatus.completed)
                          .length;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          count.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Finished"),
                    Obx(() {
                      final count = controller.downloads
                          .where((t) => t.status == DownloadStatus.completed)
                          .length;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          count.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Obx(() {
              final ongoing = controller.downloads
                  .where((t) => t.status != DownloadStatus.completed)
                  .toList();
              if (ongoing.isEmpty) {
                return const Center(
                  child: Text(
                    "No active downloads",
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ongoing.length,
                itemBuilder: (context, index) =>
                    DownloadMediaCard(task: ongoing[index]),
              );
            }),
            Obx(() {
              final finished = controller.downloads
                  .where((t) => t.status == DownloadStatus.completed)
                  .toList();

              if (finished.isEmpty) {
                return const Center(
                  child: Text(
                    "No finished downloads",
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: finished.length,
                itemBuilder: (context, index) =>
                    DownloadMediaCard(task: finished[index]),
              );
            }),
          ],
        ),
      ),
    );
  }
}
