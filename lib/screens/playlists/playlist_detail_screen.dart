import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../main.dart';
import '../../widgets/confirm_dialog.dart';
import 'playlist_track_row.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final int playlistId;
  final VoidCallback onBack;

  const PlaylistDetailScreen({super.key, required this.playlistId, required this.onBack});

  Future<void> _deletePlaylist(BuildContext context, String name) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete playlist',
      message: 'Delete "$name"? The tracks themselves are not affected.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed) {
      await database.deletePlaylist(playlistId);
      onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Playlist>>(
      stream: database.watchPlaylists(),
      builder: (context, playlistSnapshot) {
        final playlist = (playlistSnapshot.data ?? []).where((p) => p.id == playlistId).firstOrNull;
        final name = playlist?.name ?? 'Playlist';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => _deletePlaylist(context, name),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<TrackWithArt>>(
                stream: database.watchPlaylistTracksWithArt(playlistId),
                builder: (context, snapshot) {
                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tracks yet — add tracks from your library using the queue icon',
                        style: TextStyle(color: Colors.white38),
                      ),
                    );
                  }

                  return ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: items.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final movedTrackId = items[oldIndex].track.id;
                      database.reorderPlaylistTrack(playlistId, movedTrackId, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return PlaylistTrackRow(
                        key: ValueKey(item.track.id),
                        data: item,
                        index: index,
                        onTap: () => playerController.playQueue(items, index),
                        onRemove: () => database.removeTrackFromPlaylist(playlistId, item.track.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}