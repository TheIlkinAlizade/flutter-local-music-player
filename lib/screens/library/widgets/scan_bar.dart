import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
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
    final folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath == null) return;

    setState(() {
      _scanning = true;
      _processed = 0;
      _skipped = 0;
      _currentFile = null;
      _errorMessage = null;
    });

    try {
      final folderId = await database.addLibraryFolder(LibraryFoldersCompanion.insert(
        identifier: folderPath,
        displayName: folderPath.split(Platform.pathSeparator).last,
        identifierType: FolderIdentifierType.filesystemPath,
      ));

      final indexer = LibraryIndexer(db: database);

      _subscription = indexer.indexFolder(folderPath).listen(
        (progress) {
          if (!mounted) return;
          setState(() {
            _processed = progress.filesProcessed;
            _skipped = progress.filesSkippedUnchanged;
            _currentFile = progress.currentFile;
          });
        },
        onDone: () async {
          await database.markFolderScanned(folderId, DateTime.now());
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
            _errorMessage = 'Scan failed: $error';
          });
        },
      );
    } catch (error) {
      setState(() {
        _scanning = false;
        _errorMessage = 'Could not start scan: $error';
      });
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _scanning ? null : _pickAndScan,
            icon: const Icon(Icons.create_new_folder_rounded, size: 18),
            label: Text(_scanning ? 'Scanning…' : 'Add Folder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          if (_scanning) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: _cancelScan,
              style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
              child: const Text('Cancel'),
            ),
          ],
          const SizedBox(width: 16),
          if (_scanning)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Processed $_processed · Skipped $_skipped',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  if (_currentFile != null)
                    Text(
                      _currentFile!,
                      style: const TextStyle(color: AppColors.textDisabled, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          if (_errorMessage != null)
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.accentRed, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}