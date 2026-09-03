import 'dart:typed_data';

class ScannedTrack {
  final String filePath;
  final String title;
  final String artist;
  final String? albumArtist;
  final String album;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final int? discNumber;
  final int durationMs;
  final int fileSizeBytes;
  final DateTime fileModifiedAt;
  final EmbeddedArt? art;

  const ScannedTrack({
    required this.filePath,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.fileSizeBytes,
    required this.fileModifiedAt,
    this.albumArtist,
    this.genre,
    this.year,
    this.trackNumber,
    this.discNumber,
    this.art,
  });
}

class EmbeddedArt {
  final Uint8List bytes;
  final String mimeType;

  const EmbeddedArt({required this.bytes, required this.mimeType});
}