import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/nav_item.dart';
import 'nav_destination.dart';

class Sidebar extends StatelessWidget {
  final bool collapsed;
  final NavDestination selected;
  final ValueChanged<NavDestination> onSelect;
  final VoidCallback onToggleCollapsed;
  final VoidCallback onCreatePlaylist;
  final List<String> playlistNames;

  const Sidebar({
    super.key,
    required this.collapsed,
    required this.selected,
    required this.onSelect,
    required this.onToggleCollapsed,
    required this.onCreatePlaylist,
    required this.playlistNames,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: collapsed ? 76 : 240,
      margin: const EdgeInsets.all(12),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment:
                    collapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                children: [
                  if (!collapsed)
                    const Text(
                      'Library',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        collapsed ? Icons.chevron_right : Icons.chevron_left,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: onToggleCollapsed,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: selected == NavDestination.library,
              collapsed: collapsed,
              onTap: () => onSelect(NavDestination.library),
            ),
            NavItem(
              icon: Icons.favorite_rounded,
              label: 'Favorites',
              selected: selected == NavDestination.favorites,
              collapsed: collapsed,
              onTap: () => onSelect(NavDestination.favorites),
            ),
            NavItem(
              icon: Icons.person_rounded,
              label: 'Artists',
              selected: selected == NavDestination.artists,
              collapsed: collapsed,
              onTap: () => onSelect(NavDestination.artists),
            ),
            NavItem(
              icon: Icons.album_rounded,
              label: 'Albums',
              selected: selected == NavDestination.albums,
              collapsed: collapsed,
              onTap: () => onSelect(NavDestination.albums),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Divider(height: 1, color: AppColors.border),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment:
                    collapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                children: [
                  if (!collapsed)
                    const Text(
                      'Playlists',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.textSecondary),
                    onPressed: onCreatePlaylist,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: playlistNames.length,
                itemBuilder: (context, index) => NavItem(
                  icon: Icons.queue_music_rounded,
                  label: playlistNames[index],
                  selected: false,
                  collapsed: collapsed,
                  onTap: () {},
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Divider(height: 1, color: AppColors.border),
            ),
            NavItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              selected: selected == NavDestination.settings,
              collapsed: collapsed,
              onTap: () => onSelect(NavDestination.settings),
            ),
          ],
        ),
      ),
    );
  }
}