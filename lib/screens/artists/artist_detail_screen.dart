import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../main.dart';
import '../library/widgets/track_list_row.dart';

class ArtistDetailScreen extends StatelessWidget {
  final String artist;
  final VoidCallback onBack;

  const ArtistDetailScreen({super.key, required this.artist, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
            Text(
              artist,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<List<TrackWithArt>>(
            stream: database.watchLibrary(sortBy: TrackSortField.album, artistFilter: artist),
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return TrackListRow(
                    data: item,
                    onFavoriteToggle: (value) => database.setFavorite(item.track.id, value),
                    onTap: () => playerController.playQueue(items, index),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}