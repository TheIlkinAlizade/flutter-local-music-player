import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/scanning/cover_art_cache.dart';
import '../../core/theme/app_colors.dart';
import '../../main.dart';
import '../../widgets/confirm_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _removeFolder(BuildContext context, LibraryFolder folder) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove folder',
      message: 'Remove "${folder.displayName}" and every track indexed from it? The files on disk are not affected.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (confirmed) {
      await database.removeLibraryFolder(folder.id, folder.identifier);
    }
  }

  Future<void> _resetLibrary(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Reset library',
      message: 'This deletes every indexed track, playlist, and cached cover image. Your music files on disk are not affected. This cannot be undone.',
      confirmLabel: 'Reset Everything',
      destructive: true,
    );
    if (confirmed) {
      await database.resetLibrary();
      await CoverArtCache().clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        const Text(
          'Settings',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        const Text(
          'LIBRARY FOLDERS',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<LibraryFolder>>(
          stream: database.watchLibraryFolders(),
          builder: (context, snapshot) {
            final folders = snapshot.data ?? [];

            if (folders.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No folders added yet.', style: TextStyle(color: AppColors.textDisabled, fontSize: 13)),
              );
            }

            return Column(
              children: folders.map((folder) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_rounded, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(folder.displayName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                              Text(
                                folder.identifier,
                                style: const TextStyle(color: AppColors.textDisabled, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.accentRed),
                          onPressed: () => _removeFolder(context, folder),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 32),
        const Text(
          'DANGER ZONE',
          style: TextStyle(color: AppColors.accentRed, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _resetLibrary(context),
          icon: const Icon(Icons.delete_forever_rounded, size: 18),
          label: const Text('Reset Library'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentRed,
            side: const BorderSide(color: AppColors.accentRed),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}