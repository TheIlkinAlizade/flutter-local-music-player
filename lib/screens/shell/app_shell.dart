import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../library/library_screen.dart';
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
  NavDestination _selected = NavDestination.library;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Sidebar(
                  collapsed: _collapsed,
                  selected: _selected,
                  onSelect: (dest) => setState(() => _selected = dest),
                  onToggleCollapsed: () => setState(() => _collapsed = !_collapsed),
                  onCreatePlaylist: () {},
                  playlistNames: const [],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
                    child: LibraryScreen(favoritesOnly: _selected == NavDestination.favorites),
                  ),
                ),
              ],
            ),
          ),
          const PlayerBar(),
        ],
      ),
    );
  }
}