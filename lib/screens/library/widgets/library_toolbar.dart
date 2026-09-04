import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../library_view_mode.dart';

class LibraryToolbar extends StatelessWidget {
  final TrackSortField sortBy;
  final ValueChanged<TrackSortField> onSortChanged;
  final LibraryViewMode viewMode;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<String> onSearchChanged;

  const LibraryToolbar({
    super.key,
    required this.sortBy,
    required this.onSortChanged,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search your library',
                hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButtonHideUnderline(
          child: DropdownButton<TrackSortField>(
            value: sortBy,
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            icon: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary, size: 18),
            items: const [
              DropdownMenuItem(value: TrackSortField.dateAdded, child: Text('Recently Added')),
              DropdownMenuItem(value: TrackSortField.title, child: Text('Title')),
              DropdownMenuItem(value: TrackSortField.artist, child: Text('Artist')),
              DropdownMenuItem(value: TrackSortField.album, child: Text('Album')),
              DropdownMenuItem(value: TrackSortField.favorite, child: Text('Favorites First')),
              DropdownMenuItem(value: TrackSortField.fileSize, child: Text('File Size')),
            ],
            onChanged: (value) {
              if (value != null) onSortChanged(value);
            },
          ),
        ),
        const SizedBox(width: 12),
        _ViewToggleButton(
          icon: Icons.grid_view_rounded,
          selected: viewMode == LibraryViewMode.grid,
          onTap: () => onViewModeChanged(LibraryViewMode.grid),
        ),
        const SizedBox(width: 4),
        _ViewToggleButton(
          icon: Icons.view_list_rounded,
          selected: viewMode == LibraryViewMode.list,
          onTap: () => onViewModeChanged(LibraryViewMode.list),
        ),
      ],
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ViewToggleButton({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? AppColors.border : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: selected ? AppColors.accentBlue : AppColors.textSecondary),
      ),
    );
  }
}