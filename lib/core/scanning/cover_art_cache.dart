import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/scanned_track.dart';

class CachedArt {
  final String hash;
  final String cachedFilePath;
  final String mimeType;

  const CachedArt({
    required this.hash,
    required this.cachedFilePath,
    required this.mimeType,
  });
}

class CoverArtCache {
  Directory? _cacheDir;

  Future<Directory> _ensureCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'cover_art_cache'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  String hashBytes(Uint8List bytes) => sha256.convert(bytes).toString();

  Future<CachedArt> store(EmbeddedArt art, {bool alreadyCached = false}) async {
    final hash = hashBytes(art.bytes);
    final dir = await _ensureCacheDir();
    final ext = _extensionFor(art.mimeType);
    final filePath = p.join(dir.path, '$hash$ext');

    if (!alreadyCached) {
      final file = File(filePath);
      if (!await file.exists()) {
        await file.writeAsBytes(art.bytes, flush: true);
      }
    }

    return CachedArt(hash: hash, cachedFilePath: filePath, mimeType: art.mimeType);
  }

  Future<void> clearAll() async {
    final dir = await _ensureCacheDir();
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        await entity.delete();
      }
    }
  }

  String _extensionFor(String mimeType) {
    switch (mimeType) {
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      case 'image/jpeg':
      default:
        return '.jpg';
    }
  }
}