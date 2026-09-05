import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../library/widgets/cover_art_thumb.dart';

class ArtistTile extends StatelessWidget {
  final ArtistSummary data;
  final VoidCallback onTap;

  const ArtistTile({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CoverArtThumb(
              artPath: data.artPath,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.artist,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${data.trackCount} track${data.trackCount == 1 ? '' : 's'}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}