import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/database/app_database.dart';
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
import 'mini_player_view.dart';
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
  bool _miniPlayerActive = false;
  Size? _normalWindowSize;
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

  Future<void> _enterMiniPlayer() async {
    _normalWindowSize = await windowManager.getSize();
    await windowManager.setResizable(false);
    await windowManager.setSize(const Size(320, 320));
    setState(() => _miniPlayerActive = true);
  }

  Future<void> _exitMiniPlayer() async {
    setState(() => _miniPlayerActive = false);
    await windowManager.setResizable(true);
    await windowManager.setSize(_normalWindowSize ?? const Size(1280, 800));
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
    if (_miniPlayerActive) {
      return MiniPlayerView(onExpand: _exitMiniPlayer);
    }

    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final effectiveCollapsed = _collapsed || width < 900;
            final showQueue = _queueOpen && width >= 760;
            final barMode = width < 700 ? PlayerBarMode.compact : PlayerBarMode.full;

            return Column(
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
                            collapsed: effectiveCollapsed,
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
                      if (showQueue) QueuePanel(onClose: () => setState(() => _queueOpen = false)),
                    ],
                  ),
                ),
                PlayerBar(
                  mode: barMode,
                  queueOpen: _queueOpen,
                  onToggleQueue: () => setState(() => _queueOpen = !_queueOpen),
                  onEnterMini: _enterMiniPlayer,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}