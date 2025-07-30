import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable confirmation dialog widget
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? Colors.red : null,
            foregroundColor: isDestructive ? Colors.white : null,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
