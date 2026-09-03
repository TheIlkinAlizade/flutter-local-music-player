import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'core/database/app_database.dart';
import 'core/scanning/library_indexer.dart';
import 'main.dart';

class ScanTestScreen extends StatefulWidget {
  const ScanTestScreen({super.key});

  @override
  State<ScanTestScreen> createState() => _ScanTestScreenState();
}

class _ScanTestScreenState extends State<ScanTestScreen> {
  String _status = 'No folder scanned yet.';
  bool _scanning = false;

  Future<void> _pickAndScan() async {
    final folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath == null) return;

    setState(() {
      _scanning = true;
      _status = 'Starting scan of $folderPath';
    });

    final indexer = LibraryIndexer(db: database);

    await for (final progress in indexer.indexFolder(folderPath)) {
      setState(() {
        _status =
            'Processed: ${progress.filesProcessed}  Skipped: ${progress.filesSkippedUnchanged}\n${progress.currentFile ?? ''}';
      });
    }

    setState(() {
      _scanning = false;
      _status = '$_status\n\nScan complete.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _scanning ? null : _pickAndScan,
              child: Text(_scanning ? 'Scanning...' : 'Pick Folder & Scan'),
            ),
            const SizedBox(height: 16),
            Text(_status),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Track>>(
                stream: database.watchLibrary(),
                builder: (context, snapshot) {
                  final tracks = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return ListTile(
                        title: Text(track.title),
                        subtitle: Text('${track.artist} — ${track.album}'),
                        trailing: Text(track.artHash != null ? '🖼' : '—'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}