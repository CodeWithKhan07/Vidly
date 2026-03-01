import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_utils.dart';

class VidlyActionButton extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onValidPaste;
  final String label;

  const VidlyActionButton({
    super.key,
    required this.controller,
    required this.onValidPaste,
    this.label = "Paste",
  });

  Future<void> _handlePasteAndValidate() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String pastedText = data?.text?.trim() ?? "";

    // 2. Check if empty
    if (pastedText.isEmpty) {
      AppUtils.showToast(msg: "Clipboard is empty");
      return;
    }
    final String? validationError = VidlyValidators.validateVideoUrl(
      pastedText,
    );

    if (validationError == null) {
      controller.text = pastedText;
      HapticFeedback.lightImpact();
      onValidPaste();
      final platform = VidlyValidators.getPlatform(pastedText);
      AppUtils.showToast(msg: "${platform.name.capitalizeFirst} link detected");
    } else {
      AppUtils.showToast(msg: validationError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _handlePasteAndValidate,
        icon: const Icon(
          Icons.content_paste_rounded,
          size: 18,
          color: Colors.white,
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}
