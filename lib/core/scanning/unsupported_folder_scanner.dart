import 'music_folder_scanner.dart';

class UnsupportedFolderScanner implements MusicFolderScanner {
  @override
  Stream<String> discoverAudioFiles(String folderIdentifier) {
    throw UnimplementedError(
      'Android folder scanning is not implemented yet. Scoped storage means '
      '"pick a folder, read files under it" needs either a SAF tree URI '
      '(matches this app\'s pick-a-folder UX, but metadata_god needs a real '
      'file path so each file must be copied via ContentResolver into a '
      'local cache before extraction) or a MediaStore query (simpler, no '
      'folder picker, relies on the OS media scanner). Decide before '
      'wiring this up.',
    );
  }
}