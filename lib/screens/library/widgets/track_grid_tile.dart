import 'package:flutter/material.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/theme/app_colors.dart';
import 'cover_art_thumb.dart';

class TrackGridTile extends StatelessWidget {
  final TrackWithArt data;
  final ValueChanged<bool> onFavoriteToggle;

  const TrackGridTile({super.key, required this.data, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    final track = data.track;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: CoverArtThumb(
                artPath: data.artPath,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onFavoriteToggle(!track.isFavorite),
                child: Icon(
                  track.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18,
                  color: track.isFavorite ? AppColors.accentYellow : Colors.white70,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          track.title,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          track.artist,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}