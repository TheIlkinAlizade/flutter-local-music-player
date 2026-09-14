import 'package:flutter/services.dart';

class AndroidFileInfo {
  final int size;
  final DateTime modified;

  const AndroidFileInfo({
    required this.size,
    required this.modified,
  });
}

class AndroidStorage {
  static const MethodChannel _channel =
      MethodChannel('local_music_player/android_storage');

  static Future<String?> pickFolder() async {
    final result = await _channel.invokeMethod<String>('pickFolder');
    return result;
  }

  static Future<bool> persistTreePermission(String uri) async {
    final result = await _channel.invokeMethod<bool>(
      'persistTreePermission',
      <String, dynamic>{
        'uri': uri,
      },
    );

    return result ?? false;
  }

  static Future<List<String>> scanTree(String uri) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'scanTree',
      <String, dynamic>{
        'uri': uri,
      },
    );

    return result?.map((item) => item.toString()).toList() ??
        <String>[];
  }

  static Future<AndroidFileInfo> getFileInfo(String uri) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'getFileInfo',
      <String, dynamic>{
        'uri': uri,
      },
    );

    if (result == null) {
      throw Exception('Unable to read Android file information');
    }

    final size = (result['size'] as num?)?.toInt() ?? 0;
    final modifiedMillis =
        (result['modified'] as num?)?.toInt() ?? 0;

    return AndroidFileInfo(
      size: size,
      modified: DateTime.fromMillisecondsSinceEpoch(
        modifiedMillis,
      ),
    );
  }

  static Future<String> copyToCache(String uri) async {
    final result = await _channel.invokeMethod<String>(
      'copyToCache',
      <String, dynamic>{
        'uri': uri,
      },
    );

    if (result == null || result.isEmpty) {
      throw Exception('Unable to copy Android file to cache');
    }

    return result;
  }
}