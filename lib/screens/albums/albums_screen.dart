import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../main.dart';
import 'album_tile.dart';

class AlbumsScreen extends StatelessWidget {
  final void Function(String album, String artist) onAlbumTap;

  const AlbumsScreen({super.key, required this.onAlbumTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AlbumSummary>>(
      stream: database.watchAlbums(),
      builder: (context, snapshot) {
        final albums = snapshot.data ?? [];

        if (albums.isEmpty) {
          return const Center(
            child: Text('No albums yet — add a folder from Home', style: TextStyle(color: Colors.white38)),
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
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return AlbumTile(data: album, onTap: () => onAlbumTap(album.album, album.artist));
          },
        );
      },
    );
  }
}