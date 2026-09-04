import 'package:drift/drift.dart';

enum FolderIdentifierType {
  filesystemPath,
  androidSafTreeUri,
}

class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text().unique()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get artist => text().withDefault(const Constant(''))();
  TextColumn get albumArtist => text().nullable()();
  TextColumn get album => text().withDefault(const Constant(''))();
  TextColumn get genre => text().nullable()();
  IntColumn get year => integer().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get discNumber => integer().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get fileSizeBytes => integer().nullable()();
  DateTimeColumn get fileModifiedAt => dateTime().nullable()();
  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get artHash =>
      text().nullable().references(CoverArt, #hash, onDelete: KeyAction.setNull)();
}
class CoverArt extends Table {
  TextColumn get hash => text()();
  TextColumn get mimeType => text()();
  TextColumn get cachedFilePath => text()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();

  @override
  Set<Column> get primaryKey => {hash};
}

class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get dateCreated => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dateModified => dateTime().withDefault(currentDateAndTime)();
}

class PlaylistTracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId =>
      integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  IntColumn get trackId =>
      integer().references(Tracks, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {playlistId, trackId},
      ];
}

class LibraryFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get identifier => text().unique()();
  TextColumn get displayName => text()();
  TextColumn get identifierType => textEnum<FolderIdentifierType>()();
  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastScannedAt => dateTime().nullable()();
}