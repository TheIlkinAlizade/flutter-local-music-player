import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../library/widgets/cover_art_thumb.dart';

class PlaylistTrackRow extends StatelessWidget {
  final TrackWithArt data;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final int index;

  const PlaylistTrackRow({
    super.key,
    required this.data,
    required this.onTap,
    required this.onRemove,
    required this.index,
  });

  String _formatDuration(int durationMs) {
    final totalSeconds = durationMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final track = data.track;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.drag_indicator_rounded, size: 18, color: AppColors.textDisabled),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  CoverArtThumb(artPath: data.artPath, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(track.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(track.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(_formatDuration(track.durationMs), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.right),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textDisabled),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}