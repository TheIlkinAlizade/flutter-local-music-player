import 'package:audio_service/audio_service.dart';

import 'player_controller.dart';

class AppAudioHandler extends BaseAudioHandler with SeekHandler {
  final PlayerController controller;

  String? _lastTrackKey;
  Duration? _lastDuration;
  bool? _lastPlaying;
  bool? _lastLoading;
  Duration _lastPushedPosition = Duration.zero;
  DateTime _lastPushedAt = DateTime.now();

  AppAudioHandler(this.controller) {
    controller.addListener(_sync);
    _sync();
  }

  void _sync() {
    final track = controller.currentTrack;

    if (track == null) {
      if (_lastTrackKey != null) {
        _lastTrackKey = null;
        mediaItem.add(null);
        playbackState.add(PlaybackState(processingState: AudioProcessingState.idle));
      }
      return;
    }

    final trackKey = track.track.filePath;
    final duration = controller.duration;
    final trackChanged = trackKey != _lastTrackKey;
    final durationChanged = duration != _lastDuration;

    if (trackChanged || durationChanged) {
      _lastTrackKey = trackKey;
      _lastDuration = duration;
      mediaItem.add(
        MediaItem(
          id: trackKey,
          title: track.track.title,
          artist: track.track.artist,
          duration: duration,
          artUri: track.artPath != null ? Uri.file(track.artPath!) : null,
        ),
      );
    }

    final playing = controller.isPlaying;
    final loading = controller.isLoading;
    final position = controller.position;
    final sinceLastPush = DateTime.now().difference(_lastPushedAt);
    final expected = playing ? _lastPushedPosition + sinceLastPush : _lastPushedPosition;
    final drift = (position - expected).abs();

    final shouldPush = trackChanged ||
        playing != _lastPlaying ||
        loading != _lastLoading ||
        drift > const Duration(milliseconds: 1500);

    if (!shouldPush) return;

    _lastPlaying = playing;
    _lastLoading = loading;
    _lastPushedPosition = position;
    _lastPushedAt = DateTime.now();

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: loading ? AudioProcessingState.loading : AudioProcessingState.ready,
        playing: playing,
        updatePosition: position,
        speed: 1.0,
      ),
    );
  }

  @override
  Future<void> play() async {
    if (!controller.isPlaying) await controller.togglePlayPause();
  }

  @override
  Future<void> pause() async {
    if (controller.isPlaying) await controller.togglePlayPause();
  }

  @override
  Future<void> stop() async {
    if (controller.isPlaying) await controller.togglePlayPause();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => controller.seek(position);

  @override
  Future<void> skipToNext() => controller.next();

  @override
  Future<void> skipToPrevious() => controller.previous();
}