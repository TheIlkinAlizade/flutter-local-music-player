import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

enum TrackSortField { title, artist, album, dateAdded, fileSize, favorite }

class TrackWithArt {
  final Track track;
  final String? artPath;

  const TrackWithArt({required this.track, this.artPath});
}

class ArtistSummary {
  final String artist;
  final int trackCount;
  final String? artPath;

  const ArtistSummary({required this.artist, required this.trackCount, this.artPath});
}

class AlbumSummary {
  final String album;
  final String artist;
  final int trackCount;
  final String? artPath;

  const AlbumSummary({required this.album, required this.artist, required this.trackCount, this.artPath});
}

@DriftDatabase(tables: [Tracks, CoverArt, Playlists, PlaylistTracks, LibraryFolders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'local_music_player'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(tracks, tracks.isFavorite);
          }
        },
      );

  Future<int> upsertTrack(TracksCompanion track) {
    return into(tracks).insertOnConflictUpdate(track);
  }

  Future<DateTime?> fileModifiedAtFor(String filePath) async {
    final row = await (select(tracks)
          ..where((t) => t.filePath.equals(filePath))
          ..limit(1))
        .getSingleOrNull();
    return row?.fileModifiedAt;
  }

  Future<void> deleteTracksNotInPaths(Set<String> keepPaths) async {
    if (keepPaths.isEmpty) {
      await delete(tracks).go();
      return;
    }
    await (delete(tracks)..where((t) => t.filePath.isNotIn(keepPaths))).go();
  }
  
  Future<void> deleteTracksUnderFolderNotInPaths(String folderRoot, Set<String> keepPaths) async {
    if (keepPaths.isEmpty) {
      await (delete(tracks)..where((t) => t.filePath.like('$folderRoot%'))).go();
      return;
    }
    await (delete(tracks)
          ..where((t) => t.filePath.like('$folderRoot%') & t.filePath.isNotIn(keepPaths)))
        .go();
  }
  
  Stream<List<TrackWithArt>> watchLibrary({
    TrackSortField sortBy = TrackSortField.dateAdded,
    bool ascending = true,
    String? searchQuery,
    bool favoritesOnly = false,
    String? artistFilter,
    String? albumFilter,
  }) {
    final query = select(tracks).join([
      leftOuterJoin(coverArt, coverArt.hash.equalsExp(tracks.artHash)),
    ]);

    if (favoritesOnly) {
      query.where(tracks.isFavorite.equals(true));
    }

    if (artistFilter != null) {
      query.where(tracks.artist.equals(artistFilter));
    }

    if (albumFilter != null) {
      query.where(tracks.album.equals(albumFilter));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      query.where(tracks.title.like(q) | tracks.artist.like(q) | tracks.album.like(q));
    }

    switch (sortBy) {
      case TrackSortField.title:
        query.orderBy([OrderingTerm(expression: tracks.title, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
      case TrackSortField.artist:
        query.orderBy([OrderingTerm(expression: tracks.artist, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
      case TrackSortField.album:
        query.orderBy([OrderingTerm(expression: tracks.album, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
      case TrackSortField.dateAdded:
        query.orderBy([OrderingTerm(expression: tracks.dateAdded, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
      case TrackSortField.fileSize:
        query.orderBy([OrderingTerm(expression: tracks.fileSizeBytes, mode: ascending ? OrderingMode.asc : OrderingMode.desc)]);
      case TrackSortField.favorite:
        query.orderBy([
          OrderingTerm(expression: tracks.isFavorite, mode: OrderingMode.desc),
          OrderingTerm(expression: tracks.title, mode: OrderingMode.asc),
        ]);
    }

    return query.watch().map((rows) => rows
        .map((row) => TrackWithArt(
              track: row.readTable(tracks),
              artPath: row.readTableOrNull(coverArt)?.cachedFilePath,
            ))
        .toList());
  }
  
  Future<void> setFavorite(int trackId, bool isFavorite) {
    return (update(tracks)..where((t) => t.id.equals(trackId)))
        .write(TracksCompanion(isFavorite: Value(isFavorite)));
  }
  
  Future<bool> coverArtExists(String hash) async {
    final row = await (select(coverArt)..where((c) => c.hash.equals(hash))).getSingleOrNull();
    return row != null;
  }

  Future<void> upsertCoverArt(CoverArtCompanion art) {
    return into(coverArt).insertOnConflictUpdate(art);
  }

  Future<int> addLibraryFolder(LibraryFoldersCompanion folder) async {
    final identifier = folder.identifier.value;
    final existing = await (select(libraryFolders)..where((f) => f.identifier.equals(identifier)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(libraryFolders).insert(folder);
  }

  Future<List<LibraryFolder>> allLibraryFolders() => select(libraryFolders).get();

  Future<void> markFolderScanned(int folderId, DateTime when) {
    return (update(libraryFolders)..where((f) => f.id.equals(folderId)))
        .write(LibraryFoldersCompanion(lastScannedAt: Value(when)));
  }
  
    Stream<List<ArtistSummary>> watchArtists() {
    final query = selectOnly(tracks)
      ..addColumns([tracks.artist, tracks.id.count(), coverArt.cachedFilePath.max()])
      ..join([leftOuterJoin(coverArt, coverArt.hash.equalsExp(tracks.artHash))])
      ..groupBy([tracks.artist])
      ..orderBy([OrderingTerm.asc(tracks.artist)]);

    return query.watch().map((rows) => rows
        .map((row) => ArtistSummary(
              artist: row.read(tracks.artist)!,
              trackCount: row.read(tracks.id.count())!,
              artPath: row.read(coverArt.cachedFilePath.max()),
            ))
        .toList());
  }

  Stream<List<AlbumSummary>> watchAlbums() {
    final query = selectOnly(tracks)
      ..addColumns([tracks.album, tracks.artist, tracks.id.count(), coverArt.cachedFilePath.max()])
      ..join([leftOuterJoin(coverArt, coverArt.hash.equalsExp(tracks.artHash))])
      ..groupBy([tracks.album, tracks.artist])
      ..orderBy([OrderingTerm.asc(tracks.album)]);

    return query.watch().map((rows) => rows
        .map((row) => AlbumSummary(
              album: row.read(tracks.album)!,
              artist: row.read(tracks.artist)!,
              trackCount: row.read(tracks.id.count())!,
              artPath: row.read(coverArt.cachedFilePath.max()),
            ))
        .toList());
  }

}