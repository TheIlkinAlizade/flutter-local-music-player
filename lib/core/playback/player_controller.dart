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

  int _loadToken = 0;
  bool _isLoading = false;

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

  Future<void> next() => _advance(forward: true, allowWrapWithoutRepeat: false);

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

  Future<void> _advance({required bool forward, required bool allowWrapWithoutRepeat, int attemptsLeft = 0}) async {
    if (_playOrder.isEmpty) return;

    final maxAttempts = attemptsLeft == 0 ? _playOrder.length : attemptsLeft;

    if (_orderPosition < _playOrder.length - 1) {
      _orderPosition++;
    } else if (_repeatMode == RepeatMode.all || allowWrapWithoutRepeat) {
      _orderPosition = 0;
    } else {
      await _player.pause();
      await _player.seek(Duration.zero);
      return;
    }

    final succeeded = await _loadCurrent(play: true);
    if (!succeeded && maxAttempts > 1) {
      await _advance(forward: forward, allowWrapWithoutRepeat: allowWrapWithoutRepeat, attemptsLeft: maxAttempts - 1);
    }
  }

  Future<bool> _loadCurrent({required bool play}) async {
    final track = currentTrack;
    if (track == null) return false;

    final myToken = ++_loadToken;
    _isLoading = true;

    bool success = false;
    try {
      await _player.setFilePath(track.track.filePath);
      if (myToken != _loadToken) return false;
      if (play) await _player.play();
      success = true;
    } catch (_) {
      success = false;
    } finally {
      if (myToken == _loadToken) {
        _isLoading = false;
        notifyListeners();
      }
    }

    return success;
  }

  void _handlePlayerStateChange(PlayerState state) {
    if (_isLoading) return;
    notifyListeners();
    if (state.processingState == ProcessingState.completed) {
      if (_repeatMode == RepeatMode.one) {
        _player.seek(Duration.zero).then((_) => _player.play());
      } else {
        _advance(forward: true, allowWrapWithoutRepeat: false);
      }
    }
  }
  
    List<TrackWithArt> get upcoming {
    final result = <TrackWithArt>[];
    for (var i = _orderPosition + 1; i < _playOrder.length; i++) {
      result.add(_queue[_playOrder[i]]);
    }
    return result;
  }

  void removeUpcomingAt(int upcomingIndex) {
    final actualIndex = _orderPosition + 1 + upcomingIndex;
    if (actualIndex < 0 || actualIndex >= _playOrder.length) return;
    _playOrder.removeAt(actualIndex);
    notifyListeners();
  }

  void reorderUpcoming(int oldIndex, int newIndex) {
    final base = _orderPosition + 1;
    final actualOld = base + oldIndex;
    final actualNew = base + newIndex;
    if (actualOld < 0 || actualOld >= _playOrder.length) return;
    final item = _playOrder.removeAt(actualOld);
    _playOrder.insert(actualNew.clamp(base, _playOrder.length), item);
    notifyListeners();
  }

  Future<void> playUpcomingAt(int upcomingIndex) async {
    final actualIndex = _orderPosition + 1 + upcomingIndex;
    if (actualIndex < 0 || actualIndex >= _playOrder.length) return;
    _orderPosition = actualIndex;
    await _loadCurrent(play: true);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}