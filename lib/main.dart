import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'core/playback/player_controller.dart';
import 'core/scanning/metadata_extractor.dart';
import 'screens/shell/app_shell.dart';

late final AppDatabase database;
late final PlayerController playerController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // window_manager is only supported on desktop platforms.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }

  await MetadataExtractor.initialize();

  database = AppDatabase();
  playerController = PlayerController();

  runApp(const LocalMusicPlayerApp());
}

class LocalMusicPlayerApp extends StatelessWidget {
  const LocalMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Music Player',
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}