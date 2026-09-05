import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../main.dart';
import 'artist_tile.dart';

class ArtistsScreen extends StatelessWidget {
  final ValueChanged<String> onArtistTap;

  const ArtistsScreen({super.key, required this.onArtistTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ArtistSummary>>(
      stream: database.watchArtists(),
      builder: (context, snapshot) {
        final artists = snapshot.data ?? [];

        if (artists.isEmpty) {
          return const Center(
            child: Text('No artists yet — add a folder from Home', style: TextStyle(color: Colors.white38)),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            mainAxisSpacing: 20,
            crossAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return ArtistTile(data: artist, onTap: () => onArtistTap(artist.artist));
          },
        );
      },
    );
  }
}