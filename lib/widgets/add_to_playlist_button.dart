import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../main.dart';

class AddToPlaylistButton extends StatelessWidget {
  final int trackId;

  const AddToPlaylistButton({super.key, required this.trackId});

  Future<void> _showPicker(BuildContext context) async {
    final playlists = await database.watchPlaylists().first;

    if (!context.mounted) return;

    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a playlist first using the + in the sidebar')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: playlists.map((playlist) {
              return ListTile(
                leading: const Icon(Icons.queue_music_rounded, color: AppColors.textSecondary),
                title: Text(playlist.name, style: const TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  database.addTrackToPlaylist(playlist.id, trackId);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.playlist_add_rounded, size: 18, color: AppColors.textDisabled),
      onPressed: () => _showPicker(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      visualDensity: VisualDensity.compact,
    );
  }
}