import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/app_utils.dart';

class VidlyInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPaste;
  final String hintText;

  const VidlyInputField({
    super.key,
    required this.controller,
    required this.onPaste,
    this.hintText = "Paste URL",
  });

  Future<void> _handlePaste() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      controller.text = data.text!;
      onPaste();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: TextFormField(
        controller: controller,
        enableInteractiveSelection: true,
        selectionControls: MaterialTextSelectionControls(),
        contextMenuBuilder: (context, editableTextState) {
          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: editableTextState.contextMenuAnchors,
            buttonItems: editableTextState.contextMenuButtonItems,
          );
        },
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        validator: (value) {
          return VidlyValidators.validateVideoUrl(value);
        },
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: InputBorder.none,
          prefixIcon: IconButton(
            icon: const Icon(
              Icons.assignment_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: _handlePaste,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              return value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => controller.clear(),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
