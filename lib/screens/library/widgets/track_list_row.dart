import 'package:flutter/material.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/theme/app_colors.dart';
import 'cover_art_thumb.dart';

class TrackListRow extends StatelessWidget {
  final TrackWithArt data;
  final ValueChanged<bool> onFavoriteToggle;
  final VoidCallback onTap;

  const TrackListRow({super.key, required this.data, required this.onFavoriteToggle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final track = data.track;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            CoverArtThumb(artPath: data.artPath, size: 40),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(track.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(track.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(track.album, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(
              width: 60,
              child: Text(_formatDuration(track.durationMs), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.right),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => onFavoriteToggle(!track.isFavorite),
              child: Icon(
                track.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 16,
                color: track.isFavorite ? AppColors.accentYellow : AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int durationMs) {
    final totalSeconds = durationMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}