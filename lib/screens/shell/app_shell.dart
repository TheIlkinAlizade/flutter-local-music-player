import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../main.dart';
import '../../widgets/dynamic_background.dart';
import '../../widgets/text_input_dialog.dart';
import '../albums/album_detail_screen.dart';
import '../albums/albums_screen.dart';
import '../artists/artist_detail_screen.dart';
import '../artists/artists_screen.dart';
import '../library/library_screen.dart';
import '../playlists/playlist_detail_screen.dart';
import '../queue/queue_panel.dart';
import '../settings/settings_screen.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _collapsed = false;
  bool _queueOpen = false;
  bool _miniPlayerActive = false;
  Size? _normalWindowSize;
  NavDestination _selected = NavDestination.library;
  String? _openArtist;
  ({String album, String artist})? _openAlbum;
  int? _openPlaylistId;

  bool get _isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  bool get _detailOpen => _openArtist != null || _openAlbum != null || _openPlaylistId != null;

  String get _destinationTitle => switch (_selected) {
        NavDestination.library => 'Home',
        NavDestination.favorites => 'Favorites',
        NavDestination.artists => 'Artists',
        NavDestination.albums => 'Albums',
        NavDestination.settings => 'Settings',
      };

  void _selectDestination(NavDestination destination) {
    setState(() {
      _selected = destination;
      _openArtist = null;
      _openAlbum = null;
      _openPlaylistId = null;
    });
  }

  void _openPlaylist(int id) {
    setState(() {
      _openPlaylistId = id;
      _openArtist = null;
      _openAlbum = null;
    });
  }

  Future<void> _enterMiniPlayer() async {
    if (_isDesktop) {
      _normalWindowSize = await windowManager.getSize();
      await windowManager.setResizable(false);
      await windowManager.setSize(const Size(320, 320));
    }
    if (mounted) setState(() => _miniPlayerActive = true);
  }

  Future<void> _exitMiniPlayer() async {
    if (mounted) setState(() => _miniPlayerActive = false);
    if (_isDesktop) {
      await windowManager.setResizable(true);
      await windowManager.setSize(_normalWindowSize ?? const Size(1280, 800));
    }
  }

  void _handleBack() {
    if (_miniPlayerActive) {
      _exitMiniPlayer();
      return;
    }
    setState(() {
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

  Widget _buildPhoneLayout() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        width: 268,
        child: SafeArea(
          child: StreamBuilder<List<Playlist>>(
            stream: database.watchPlaylists(),
            builder: (context, snapshot) {
              return Sidebar(
                collapsed: false,
                selected: _selected,
                onSelect: (destination) {
                  Navigator.of(context).pop();
                  _selectDestination(destination);
                },
                onToggleCollapsed: () => Navigator.of(context).pop(),
                onCreatePlaylist: () {
                  Navigator.of(context).pop();
                  _createPlaylist();
                },
                playlists: snapshot.data ?? [],
                openPlaylistId: _openPlaylistId,
                onPlaylistTap: (id) {
                  Navigator.of(context).pop();
                  _openPlaylist(id);
                },
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_detailOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(
                      child: Text(
                        _destinationTitle,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildContent(),
              ),
            ),
            PlayerBar(
              mode: PlayerBarMode.slim,
              queueOpen: false,
              onToggleQueue: () {},
              onEnterMini: _enterMiniPlayer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(double width) {
    final effectiveCollapsed = _collapsed || width < 900;
    final showQueue = _queueOpen && width >= 760;
    final barMode = width < 760 ? PlayerBarMode.compact : PlayerBarMode.full;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StreamBuilder<List<Playlist>>(
                  stream: database.watchPlaylists(),
                  builder: (context, snapshot) {
                    return Sidebar(
                      collapsed: effectiveCollapsed,
                      selected: _selected,
                      onSelect: _selectDestination,
                      onToggleCollapsed: () => setState(() => _collapsed = !_collapsed),
                      onCreatePlaylist: _createPlaylist,
                      playlists: snapshot.data ?? [],
                      openPlaylistId: _openPlaylistId,
                      onPlaylistTap: _openPlaylist,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_miniPlayerActive && !_detailOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: _miniPlayerActive
          ? MiniPlayerView(onExpand: _exitMiniPlayer)
          : DynamicBackground(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return width < 600 ? _buildPhoneLayout() : _buildWideLayout(width);
                },
              ),
            ),
    );
  }
}