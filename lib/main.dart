import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:window_manager/window_manager.dart';

import 'core/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'core/playback/app_audio_handler.dart';
import 'core/playback/player_controller.dart';
import 'core/scanning/metadata_extractor.dart';
import 'screens/shell/app_shell.dart';

late final AppDatabase database;
late final PlayerController playerController;
AppAudioHandler? audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // window_manager is only supported on desktop platforms.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }

  await MetadataExtractor.initialize();

  database = AppDatabase();
  playerController = PlayerController();

  if (Platform.isAndroid) {
    Permission.notification.request();

    audioHandler = await AudioService.init(
      builder: () => AppAudioHandler(playerController),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.localmusicplayer.playback',
        androidNotificationChannelName: 'Music playback',
        androidNotificationOngoing: true,
      ),
    );
  }

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