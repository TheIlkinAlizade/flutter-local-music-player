import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CoverArtThumb extends StatelessWidget {
  final String? artPath;
  final double size;
  final BorderRadius borderRadius;

  const CoverArtThumb({
    super.key,
    required this.artPath,
    required this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: size,
        height: size,
        color: AppColors.surface,
        child: artPath != null
            ? Image.file(
                File(artPath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(Icons.music_note_rounded, color: AppColors.textDisabled, size: size * 0.4),
    );
  }
}