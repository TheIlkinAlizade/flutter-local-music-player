import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../main.dart';
import '../library/widgets/track_list_row.dart';

class AlbumDetailScreen extends StatelessWidget {
  final String album;
  final String artist;
  final VoidCallback onBack;

  const AlbumDetailScreen({super.key, required this.album, required this.artist, required this.onBack});

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Text(artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<List<TrackWithArt>>(
            stream: database.watchLibrary(albumFilter: album, artistFilter: artist),
            builder: (context, snapshot) {
              final items = List<TrackWithArt>.from(snapshot.data ?? []);
              items.sort((a, b) {
                final discA = a.track.discNumber ?? 0;
                final discB = b.track.discNumber ?? 0;
                if (discA != discB) return discA.compareTo(discB);
                final trackA = a.track.trackNumber ?? 0;
                final trackB = b.track.trackNumber ?? 0;
                return trackA.compareTo(trackB);
              });

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return TrackListRow(
                    data: item,
                    onFavoriteToggle: (value) => database.setFavorite(item.track.id, value),
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