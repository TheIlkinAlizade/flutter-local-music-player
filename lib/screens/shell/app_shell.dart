import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../main.dart';
import '../../widgets/text_input_dialog.dart';
import '../albums/album_detail_screen.dart';
import '../albums/albums_screen.dart';
import '../artists/artist_detail_screen.dart';
import '../artists/artists_screen.dart';
import '../library/library_screen.dart';
import '../playlists/playlist_detail_screen.dart';
import '../queue/queue_panel.dart';
import '../settings/settings_screen.dart';
import '../../widgets/dynamic_background.dart';
import 'nav_destination.dart';
import 'player_bar.dart';
import 'sidebar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _collapsed = false;
  bool _queueOpen = false;
  NavDestination _selected = NavDestination.library;
  String? _openArtist;
  ({String album, String artist})? _openAlbum;
  int? _openPlaylistId;

  void _selectDestination(NavDestination destination) {
    setState(() {
      _selected = destination;
      _openArtist = null;
      _openAlbum = null;
      _openPlaylistId = null;
    });
  }

  Future<void> _createPlaylist() async {
    final name = await showTextInputDialog(
      context,
      title: 'New Playlist',
      hintText: 'Playlist name',
    );
    if (name != null && name.isNotEmpty) {
      await database.createPlaylist(name);
    }
  }

  Widget _buildContent() {
    if (_openArtist != null) {
      return ArtistDetailScreen(artist: _openArtist!, onBack: () => setState(() => _openArtist = null));
    }

    if (_openAlbum != null) {
      return AlbumDetailScreen(
        album: _openAlbum!.album,
        artist: _openAlbum!.artist,
        onBack: () => setState(() => _openAlbum = null),
      );
    }

    if (_openPlaylistId != null) {
      return PlaylistDetailScreen(playlistId: _openPlaylistId!, onBack: () => setState(() => _openPlaylistId = null));
    }

    switch (_selected) {
      case NavDestination.library:
        return const LibraryScreen(favoritesOnly: false);
      case NavDestination.favorites:
        return const LibraryScreen(favoritesOnly: true);
      case NavDestination.artists:
        return ArtistsScreen(onArtistTap: (artist) => setState(() => _openArtist = artist));
      case NavDestination.albums:
        return AlbumsScreen(
          onAlbumTap: (album, artist) => setState(() => _openAlbum = (album: album, artist: artist)),
        );
      case NavDestination.settings:
        return const SettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicBackground(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StreamBuilder<List<Playlist>>(
                    stream: database.watchPlaylists(),
                    builder: (context, snapshot) {
                      final playlists = snapshot.data ?? [];
                      return Sidebar(
                        collapsed: _collapsed,
                        selected: _selected,
                        onSelect: _selectDestination,
                        onToggleCollapsed: () => setState(() => _collapsed = !_collapsed),
                        onCreatePlaylist: _createPlaylist,
                        playlists: playlists,
                        openPlaylistId: _openPlaylistId,
                        onPlaylistTap: (id) => setState(() {
                          _openPlaylistId = id;
                          _openArtist = null;
                          _openAlbum = null;
                        }),
                      );
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
                      child: _buildContent(),
                    ),
                  ),
                  if (_queueOpen) QueuePanel(onClose: () => setState(() => _queueOpen = false)),
                ],
              ),
            ),
            PlayerBar(
              queueOpen: _queueOpen,
              onToggleQueue: () => setState(() => _queueOpen = !_queueOpen),
            ),
          ],
        ),
      )
    );
  }
}