import 'dart:io';

import 'package:path/path.dart' as p;

import 'music_folder_scanner.dart';

class IoFolderScanner implements MusicFolderScanner {
  @override
  Stream<String> discoverAudioFiles(String folderIdentifier) async* {
    final root = Directory(folderIdentifier);
    if (!await root.exists()) return;

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (_isHidden(entity.path)) continue;

      final ext = p.extension(entity.path).toLowerCase();
      if (audioFileExtensions.contains(ext)) {
        yield entity.path;
      }
    }
  }

  bool _isHidden(String path) {
    return p.split(path).any((segment) => segment.startsWith('.'));
  }
}