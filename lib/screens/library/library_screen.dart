import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class LibraryScreen extends StatelessWidget {
  final bool favoritesOnly;

  const LibraryScreen({super.key, required this.favoritesOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        favoritesOnly ? 'Favorites' : 'Library',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}