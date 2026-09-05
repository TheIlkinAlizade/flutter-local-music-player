import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../database/app_database.dart';

enum RepeatMode { off, all, one }

class PlayerController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<TrackWithArt> _queue = [];
  List<int> _playOrder = [];
  int _orderPosition = 0;
  bool _shuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;

  PlayerController() {
    _player.playerStateStream.listen(_handlePlayerStateChange);
    _player.positionStream.listen((_) => notifyListeners());
  }

  int get _currentQueueIndex => _playOrder.isEmpty ? -1 : _playOrder[_orderPosition];

  TrackWithArt? get currentTrack {
    final index = _currentQueueIndex;
    if (index < 0 || index >= _queue.length) return null;
    return _queue[index];
  }

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get shuffleEnabled => _shuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;

  Future<void> playQueue(List<TrackWithArt> queue, int startIndex) async {
    _queue = queue;
    _rebuildPlayOrder(keepTrackIndex: startIndex);
    await _loadCurrent(play: true);
  }

  Future<void> togglePlayPause() async {
    if (_queue.isEmpty) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> next() async {
    if (_playOrder.isEmpty) return;
    if (_orderPosition < _playOrder.length - 1) {
      _orderPosition++;
      await _loadCurrent(play: true);
    } else if (_repeatMode == RepeatMode.all) {
      _orderPosition = 0;
      await _loadCurrent(play: true);
    } else {
      await _player.pause();
      await _player.seek(Duration.zero);
    }
  }

  Future<void> previous() async {
    if (_playOrder.isEmpty) return;
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_orderPosition > 0) {
      _orderPosition--;
      await _loadCurrent(play: true);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    _rebuildPlayOrder(keepTrackIndex: _currentQueueIndex);
    notifyListeners();
  }

  void cycleRepeatMode() {
    _repeatMode = switch (_repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    notifyListeners();
  }

  void _rebuildPlayOrder({required int keepTrackIndex}) {
    final indices = List<int>.generate(_queue.length, (i) => i);
    if (_shuffleEnabled) {
      indices.shuffle();
      if (keepTrackIndex >= 0) {
        indices.remove(keepTrackIndex);
        indices.insert(0, keepTrackIndex);
      }
    }
    _playOrder = indices;
    _orderPosition = keepTrackIndex >= 0 ? _playOrder.indexOf(keepTrackIndex) : 0;
  }

  Future<void> _loadCurrent({required bool play}) async {
    final track = currentTrack;
    if (track == null) return;
    await _player.setFilePath(track.track.filePath);
    if (play) await _player.play();
    notifyListeners();
  }

  void _handlePlayerStateChange(PlayerState state) {
    notifyListeners();
    if (state.processingState == ProcessingState.completed) {
      if (_repeatMode == RepeatMode.one) {
        _player.seek(Duration.zero).then((_) => _player.play());
      } else {
        next();
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}