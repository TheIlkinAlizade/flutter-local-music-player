import 'dart:io';

import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;

import '../models/scanned_track.dart';
import 'android_storage.dart';

class MetadataExtractor {
  static Future<void> initialize() =>
      MetadataGod.initialize();

  Future<ScannedTrack> extract(
    String filePath,
  ) async {
    String? temporaryPath;

    try {
      final actualPath =
          filePath.startsWith('content://')
              ? await AndroidStorage.copyToCache(
                  filePath,
                )
              : filePath;

      if (filePath.startsWith('content://')) {
        temporaryPath = actualPath;
      }

      final file = File(actualPath);

      final stat = await file.stat();

      final metadata =
          await MetadataGod.readMetadata(
        file: actualPath,
      );

      final fallbackTitle =
          p.basenameWithoutExtension(
        actualPath,
      );

      DateTime modifiedAt =
          stat.modified;

      int fileSize =
          stat.size;

      if (filePath.startsWith('content://')) {
        final androidInfo =
            await AndroidStorage.getFileInfo(
          filePath,
        );

        fileSize =
            androidInfo.size;

        modifiedAt =
            androidInfo.modified;
      }

      return ScannedTrack(
        filePath: filePath,
        title:
            _nonEmpty(metadata.title) ??
                fallbackTitle,
        artist:
            _nonEmpty(metadata.artist) ??
                'Unknown Artist',
        album:
            _nonEmpty(metadata.album) ??
                'Unknown Album',
        albumArtist:
            _nonEmpty(
              metadata.albumArtist,
            ),
        genre:
            _nonEmpty(metadata.genre),
        year:
            metadata.year,
        trackNumber:
            metadata.trackNumber,
        discNumber:
            metadata.discNumber,
        durationMs:
            metadata.durationMs
                ?.round() ??
            0,
        fileSizeBytes:
            fileSize,
        fileModifiedAt:
            modifiedAt,
        art:
            metadata.picture != null
                ? EmbeddedArt(
                    bytes:
                        metadata.picture!.data,
                    mimeType:
                        metadata.picture!.mimeType,
                  )
                : null,
      );
    } finally {
      if (temporaryPath != null) {
        try {
          final tempFile =
              File(temporaryPath);

          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (_) {}
      }
    }
  }

  String? _nonEmpty(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed =
        value.trim();

    return trimmed.isEmpty
        ? null
        : trimmed;
  }
}