import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidly/controller/download_controller.dart';
import 'package:vidly/data/models/download_model.dart';
import 'package:vidly/views/downloads/downloads_screen.dart';
import 'package:vidly/views/home/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [const HomeScreen(), const DownloadsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final downloadController = Get.find<DownloadController>();
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, "Home", Icons.home_filled, Icons.home_outlined),
          Obx(() {
            final ongoingCount = downloadController.downloads
                .where((t) => t.status != DownloadStatus.completed)
                .length;

            return _navItem(
              1,
              "Downloads",
              Icons.file_download,
              Icons.file_download_outlined,
              badgeCount: ongoingCount,
            );
          }),
        ],
      ),
    );
  }

  Widget _navItem(
    int index,
    String label,
    IconData activeIcon,
    IconData inactiveIcon, {
    int badgeCount = 0,
  }) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? Colors.white : Colors.white30,
                size: 28,
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -4,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white30,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
