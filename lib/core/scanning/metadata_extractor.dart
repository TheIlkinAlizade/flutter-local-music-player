import 'dart:io';

import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;

import '../models/scanned_track.dart';

class MetadataExtractor {
  static Future<void> initialize() => MetadataGod.initialize();

  Future<ScannedTrack> extract(String filePath) async {
    final file = File(filePath);
    final stat = await file.stat();
    final metadata = await MetadataGod.readMetadata(file: filePath);

    final fallbackTitle = p.basenameWithoutExtension(filePath);

    return ScannedTrack(
      filePath: filePath,
      title: _nonEmpty(metadata.title) ?? fallbackTitle,
      artist: _nonEmpty(metadata.artist) ?? 'Unknown Artist',
      album: _nonEmpty(metadata.album) ?? 'Unknown Album',
      albumArtist: _nonEmpty(metadata.albumArtist),
      genre: _nonEmpty(metadata.genre),
      year: metadata.year,
      trackNumber: metadata.trackNumber,
      discNumber: metadata.discNumber,
      durationMs: metadata.durationMs?.round() ?? 0,
      fileSizeBytes: stat.size,
      fileModifiedAt: stat.modified,
      art: metadata.picture != null
          ? EmbeddedArt(
              bytes: metadata.picture!.data,
              mimeType: metadata.picture!.mimeType,
            )
          : null,
    );
  }

  String? _nonEmpty(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}