import 'dart:io';

import 'android_folder_scanner.dart';
import 'io_folder_scanner.dart';
import 'unsupported_folder_scanner.dart';

const audioFileExtensions = {
  '.mp3',
  '.flac',
  '.m4a',
  '.wav',
};

abstract class MusicFolderScanner {
  Stream<String> discoverAudioFiles(String folderIdentifier);
}

MusicFolderScanner platformScanner() {
  if (Platform.isWindows) {
    return IoFolderScanner();
  }

  if (Platform.isAndroid) {
    return AndroidFolderScanner();
  }

  return UnsupportedFolderScanner();
}