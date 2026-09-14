import 'android_storage.dart';
import 'music_folder_scanner.dart';

class AndroidFolderScanner implements MusicFolderScanner {
  @override
  Stream<String> discoverAudioFiles(String folderIdentifier) async* {
    if (!folderIdentifier.startsWith('content://')) {
      throw Exception(
        'Android library folder is not a SAF URI: $folderIdentifier',
      );
    }

    final files = await AndroidStorage.scanTree(folderIdentifier);

    for (final file in files) {
      yield file;
    }
  }
}