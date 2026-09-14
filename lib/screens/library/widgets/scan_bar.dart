// ignore_for_file: unnecessary_non_null_assertion

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../../core/scanning/android_storage.dart';
import '../../../core/scanning/library_indexer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_panel.dart';
import '../../../main.dart';

class ScanBar extends StatefulWidget {
  const ScanBar({super.key});

  @override
  State<ScanBar> createState() => _ScanBarState();
}

class _ScanBarState extends State<ScanBar> {
  bool _scanning = false;
  int _processed = 0;
  int _skipped = 0;
  String? _currentFile;
  String? _errorMessage;
  StreamSubscription<IndexingProgress>? _subscription;

  Future<void> _pickAndScan() async {
    String? folderIdentifier;

    try {
      if (Platform.isAndroid) {
        folderIdentifier =
            await AndroidStorage.pickFolder();
      } else {
        folderIdentifier =
            await FilePicker.platform.getDirectoryPath();
      }

      if (folderIdentifier == null ||
          folderIdentifier!.isEmpty) {
        return;
      }

      if (Platform.isAndroid &&
          !folderIdentifier!.startsWith('content://')) {
        throw Exception(
          'Android folder picker did not return a SAF URI: '
          '$folderIdentifier',
        );
      }

      if (Platform.isAndroid) {
        await AndroidStorage.persistTreePermission(
          folderIdentifier!,
        );
      }

      setState(() {
        _scanning = true;
        _processed = 0;
        _skipped = 0;
        _currentFile = null;
        _errorMessage = null;
      });

      final identifier = folderIdentifier!;

      final folderId =
          await database.addLibraryFolder(
        LibraryFoldersCompanion.insert(
          identifier: identifier,
          displayName: _displayName(identifier),
          identifierType: Platform.isAndroid
              ? FolderIdentifierType.androidSafTreeUri
              : FolderIdentifierType.filesystemPath,
        ),
      );

      final indexer =
          LibraryIndexer(db: database);

      _subscription =
          indexer.indexFolder(identifier).listen(
        (progress) {
          if (!mounted) return;

          setState(() {
            _processed =
                progress.filesProcessed;

            _skipped =
                progress.filesSkippedUnchanged;

            _currentFile =
                progress.currentFile;
          });
        },
        onDone: () async {
          await database.markFolderScanned(
            folderId,
            DateTime.now(),
          );

          if (!mounted) return;

          setState(() {
            _scanning = false;
            _currentFile = null;
          });
        },
        onError: (Object error) {
          if (!mounted) return;

          setState(() {
            _scanning = false;
            _currentFile = null;
            _errorMessage =
                'Scan failed: $error';
          });
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _scanning = false;
        _currentFile = null;
        _errorMessage =
            'Could not start scan: $error';
      });
    }
  }

  String _displayName(String identifier) {
    if (!identifier.startsWith('content://')) {
      return identifier
          .split(Platform.pathSeparator)
          .last;
    }

    final uri =
        Uri.tryParse(identifier);

    if (uri != null &&
        uri.pathSegments.isNotEmpty) {
      final segment =
          uri.pathSegments.last;

      return Uri.decodeComponent(
        segment,
      );
    }

    return 'Music Folder';
  }

  void _cancelScan() {
    _subscription?.cancel();

    setState(() {
      _scanning = false;
      _currentFile = null;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed:
                _scanning
                    ? null
                    : _pickAndScan,
            icon: const Icon(
              Icons.create_new_folder_rounded,
              size: 18,
            ),
            label: Text(
              _scanning
                  ? 'Scanning…'
                  : 'Add Folder',
            ),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.accentBlue,
              foregroundColor:
                  Colors.black,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8),
              ),
            ),
          ),
          if (_scanning) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: _cancelScan,
              style:
                  TextButton.styleFrom(
                foregroundColor:
                    AppColors.accentRed,
              ),
              child:
                  const Text('Cancel'),
            ),
          ],
          const SizedBox(width: 16),
          if (_scanning)
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    'Processed $_processed · '
                    'Skipped $_skipped',
                    style:
                        const TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (_currentFile != null)
                    Text(
                      _currentFile!,
                      style:
                          const TextStyle(
                        color:
                            AppColors.textDisabled,
                        fontSize: 11,
                      ),
                      overflow:
                          TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          if (_errorMessage != null)
            Expanded(
              child: Text(
                _errorMessage!,
                style:
                    const TextStyle(
                  color:
                      AppColors.accentRed,
                  fontSize: 12,
                ),
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}