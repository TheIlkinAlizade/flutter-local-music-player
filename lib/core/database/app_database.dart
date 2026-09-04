import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

enum TrackSortField { title, artist, album, dateAdded, fileSize, favorite }

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

  Stream<List<Track>> watchLibrary({
    TrackSortField sortBy = TrackSortField.dateAdded,
    bool ascending = true,
    String? searchQuery,
    bool favoritesOnly = false,
  }) {
    final query = select(tracks);

    if (favoritesOnly) {
      query.where((t) => t.isFavorite.equals(true));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      query.where((t) => t.title.like(q) | t.artist.like(q) | t.album.like(q));
    }

    switch (sortBy) {
      case TrackSortField.title:
        query.orderBy([
          (t) => OrderingTerm(expression: t.title, mode: ascending ? OrderingMode.asc : OrderingMode.desc)
        ]);
      case TrackSortField.artist:
        query.orderBy([
          (t) => OrderingTerm(expression: t.artist, mode: ascending ? OrderingMode.asc : OrderingMode.desc)
        ]);
      case TrackSortField.album:
        query.orderBy([
          (t) => OrderingTerm(expression: t.album, mode: ascending ? OrderingMode.asc : OrderingMode.desc)
        ]);
      case TrackSortField.dateAdded:
        query.orderBy([
          (t) => OrderingTerm(expression: t.dateAdded, mode: ascending ? OrderingMode.asc : OrderingMode.desc)
        ]);
      case TrackSortField.fileSize:
        query.orderBy([
          (t) => OrderingTerm(expression: t.fileSizeBytes, mode: ascending ? OrderingMode.asc : OrderingMode.desc)
        ]);
      case TrackSortField.favorite:
        query.orderBy([
          (t) => OrderingTerm(expression: t.isFavorite, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc),
        ]);
    }

    return query.watch();
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

  Future<int> addLibraryFolder(LibraryFoldersCompanion folder) {
    return into(libraryFolders).insertOnConflictUpdate(folder);
  }

  Future<List<LibraryFolder>> allLibraryFolders() => select(libraryFolders).get();

  Future<void> markFolderScanned(int folderId, DateTime when) {
    return (update(libraryFolders)..where((f) => f.id.equals(folderId)))
        .write(LibraryFoldersCompanion(lastScannedAt: Value(when)));
  }
}