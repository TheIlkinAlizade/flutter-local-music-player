import 'dart:io';

import 'package:drift/drift.dart' show Value;

import '../database/app_database.dart';
import '../models/scanned_track.dart';
import 'cover_art_cache.dart';
import 'metadata_extractor.dart';
import 'music_folder_scanner.dart';

class IndexingProgress {
  final int filesProcessed;
  final int filesSkippedUnchanged;
  final String? currentFile;

  const IndexingProgress({
    required this.filesProcessed,
    required this.filesSkippedUnchanged,
    this.currentFile,
  });
}

class LibraryIndexer {
  final AppDatabase _db;
  final MusicFolderScanner _scanner;
  final MetadataExtractor _extractor;
  final CoverArtCache _artCache;

  LibraryIndexer({
    required AppDatabase db,
    MusicFolderScanner? scanner,
    MetadataExtractor? extractor,
    CoverArtCache? artCache,
  })  : _db = db,
        _scanner = scanner ?? platformScanner(),
        _extractor = extractor ?? MetadataExtractor(),
        _artCache = artCache ?? CoverArtCache();

  Stream<IndexingProgress> indexFolder(String folderIdentifier) async* {
    var processed = 0;
    var skipped = 0;
    final seenPaths = <String>{};

    await for (final filePath in _scanner.discoverAudioFiles(folderIdentifier)) {
      seenPaths.add(filePath);

      final unchanged = await _isUnchangedSinceLastScan(filePath);
      if (unchanged) {
        skipped++;
        yield IndexingProgress(
          filesProcessed: processed,
          filesSkippedUnchanged: skipped,
          currentFile: filePath,
        );
        continue;
      }

      try {
        final scanned = await _extractor.extract(filePath);
        await _persist(scanned);
      } catch (_) {}

      processed++;
      yield IndexingProgress(
        filesProcessed: processed,
        filesSkippedUnchanged: skipped,
        currentFile: filePath,
      );
    }

    await _db.deleteTracksNotInPaths(seenPaths);
  }

  Future<bool> _isUnchangedSinceLastScan(String filePath) async {
    final storedModifiedAt = await _db.fileModifiedAtFor(filePath);
    if (storedModifiedAt == null) return false;

    final currentModifiedAt = await _fileModifiedAt(filePath);
    if (currentModifiedAt == null) return false;

    return !currentModifiedAt.isAfter(storedModifiedAt);
  }

  Future<DateTime?> _fileModifiedAt(String filePath) async {
    try {
      final stat = await File(filePath).stat();
      return stat.modified;
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist(ScannedTrack scanned) async {
    String? artHash;

    if (scanned.art != null) {
      final hash = _artCache.hashBytes(scanned.art!.bytes);
      final alreadyCached = await _db.coverArtExists(hash);

      final cached = await _artCache.store(scanned.art!, alreadyCached: alreadyCached);

      if (!alreadyCached) {
        await _db.upsertCoverArt(CoverArtCompanion.insert(
          hash: cached.hash,
          mimeType: cached.mimeType,
          cachedFilePath: cached.cachedFilePath,
        ));
      }
      artHash = hash;
    }

    await _db.upsertTrack(TracksCompanion.insert(
      filePath: scanned.filePath,
      title: Value(scanned.title),
      artist: Value(scanned.artist),
      albumArtist: Value(scanned.albumArtist),
      album: Value(scanned.album),
      genre: Value(scanned.genre),
      year: Value(scanned.year),
      trackNumber: Value(scanned.trackNumber),
      discNumber: Value(scanned.discNumber),
      durationMs: Value(scanned.durationMs),
      fileSizeBytes: Value(scanned.fileSizeBytes),
      fileModifiedAt: Value(scanned.fileModifiedAt),
      artHash: Value(artHash),
    ));
  }
}