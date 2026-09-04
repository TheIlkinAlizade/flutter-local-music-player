import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'core/scanning/metadata_extractor.dart';
import 'scan_test_screen.dart';

late final AppDatabase database;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MetadataExtractor.initialize();
  database = AppDatabase();
  runApp(const LocalMusicPlayerApp());
}

class LocalMusicPlayerApp extends StatelessWidget {
  const LocalMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Music Player',
      theme: AppTheme.dark,
      home: const ScanTestScreen(),
    );
  }
}