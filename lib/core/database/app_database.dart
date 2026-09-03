import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

enum TrackSortField { title, artist, album, dateAdded }

@DriftDatabase(tables: [Tracks, CoverArt, Playlists, PlaylistTracks, LibraryFolders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'local_music_player'));

  @override
  int get schemaVersion => 1;

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
  }) {
    final query = select(tracks);

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
    }

    return query.watch();
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