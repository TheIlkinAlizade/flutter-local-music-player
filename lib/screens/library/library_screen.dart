import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../main.dart';
import 'library_view_mode.dart';
import 'widgets/library_toolbar.dart';
import 'widgets/scan_bar.dart';
import 'widgets/track_grid_tile.dart';
import 'widgets/track_list_row.dart';

class LibraryScreen extends StatefulWidget {
  final bool favoritesOnly;

  const LibraryScreen({super.key, required this.favoritesOnly});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  TrackSortField _sortBy = TrackSortField.dateAdded;
  LibraryViewMode _viewMode = LibraryViewMode.grid;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ScanBar(),
        const SizedBox(height: 12),
        LibraryToolbar(
          sortBy: _sortBy,
          onSortChanged: (value) => setState(() => _sortBy = value),
          viewMode: _viewMode,
          onViewModeChanged: (value) => setState(() => _viewMode = value),
          onSearchChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<List<TrackWithArt>>(
            stream: database.watchLibrary(
              sortBy: _sortBy,
              searchQuery: _searchQuery,
              favoritesOnly: widget.favoritesOnly,
            ),
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return Center(
                  child: Text(
                    widget.favoritesOnly ? 'No favorites yet' : 'No tracks yet — add a folder above',
                    style: const TextStyle(color: Colors.white38),
                  ),
                );
              }

              if (_viewMode == LibraryViewMode.grid) {
                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 170,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return TrackGridTile(
                      data: item,
                      onFavoriteToggle: (value) => database.setFavorite(item.track.id, value),
                      onTap: () => playerController.playQueue(items, index),
                    );
                  },
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return TrackListRow(
                    data: item,
                    onFavoriteToggle: (value) => database.setFavorite(item.track.id, value),
                    onTap: () => playerController.playQueue(items, index),
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