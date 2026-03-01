import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';
import '../widgets/button/action_button.dart';
import '../widgets/button/primary_button.dart';
import '../widgets/input_field/input_field.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.blueAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Vidly",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Download\nVideos",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Any format. Any source. Instantly.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              VidlyInputField(
                                controller: controller.urlController,
                                onPaste: () {
                                  if (_formKey.currentState!.validate()) {
                                    controller.analyzeVideoUrl();
                                  }
                                },
                              ),
                              const SizedBox(height: 25),
                              VidlyActionButton(
                                controller: controller.urlController,
                                onValidPaste: () =>
                                    controller.analyzeVideoUrl(),
                              ),
                              const SizedBox(height: 25),
                              Obx(() {
                                return AnalyzeButton(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      controller.analyzeVideoUrl();
                                    }
                                  },
                                  isLoading: controller.isLoading.value,
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
