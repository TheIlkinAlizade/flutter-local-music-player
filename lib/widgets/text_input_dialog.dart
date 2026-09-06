import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String confirmLabel = 'Create',
  String hintText = '',
}) async {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textDisabled),
          enabledBorder: InputBorder.none,
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(confirmLabel, style: const TextStyle(color: AppColors.accentBlue)),
        ),
      ],
    ),
  );
}