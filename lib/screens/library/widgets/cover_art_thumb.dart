import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CoverArtThumb extends StatelessWidget {
  final String? artPath;
  final double? size;
  final BorderRadius borderRadius;

  const CoverArtThumb({
    super.key,
    required this.artPath,
    this.size,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: size,
        height: size,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boxSize = size ?? (constraints.maxWidth.isFinite ? constraints.maxWidth : 48.0);
            return Container(
              color: AppColors.surface,
              child: artPath != null
                  ? Image.file(
                      File(artPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _placeholder(boxSize),
                    )
                  : _placeholder(boxSize),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder(double boxSize) {
    return Center(
      child: Icon(Icons.music_note_rounded, color: AppColors.textDisabled, size: boxSize * 0.4),
    );
  }
}