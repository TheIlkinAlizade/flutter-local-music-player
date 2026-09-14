import 'music_folder_scanner.dart';

class UnsupportedFolderScanner implements MusicFolderScanner {
  @override
  Stream<String> discoverAudioFiles(String folderIdentifier) {
    throw UnsupportedError(
      'Folder scanning is not supported on this platform.',
    );
  }
}