import 'package:flutter/material.dart' hide RepeatMode;


import '../../core/playback/player_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../main.dart';
import '../library/widgets/cover_art_thumb.dart';
import '../../widgets/glass_panel.dart';

class PlayerBar extends StatelessWidget {
  final bool queueOpen;
  final VoidCallback onToggleQueue;

  const PlayerBar({super.key, required this.queueOpen, required this.onToggleQueue});
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SizedBox(
        height: 96,
        child: GlassPanel(
          backgroundColor: AppColors.surfaceGlassSolid,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedBuilder(
            animation: playerController,
            builder: (context, _) {
              final track = playerController.currentTrack;
              final position = playerController.position;
              final duration = playerController.duration ?? Duration.zero;
              final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
              final valueMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

              return Row(
                children: [
                  CoverArtThumb(artPath: track?.artPath, size: 56, borderRadius: BorderRadius.circular(8)),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track?.track.title ?? 'No track playing',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track?.track.artist ?? '—',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.shuffle_rounded, size: 18),
                              color: playerController.shuffleEnabled ? AppColors.accentBlue : AppColors.textDisabled,
                              onPressed: playerController.toggleShuffle,
                              visualDensity: VisualDensity.compact
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_previous_rounded, size: 22, color: AppColors.textSecondary),
                              onPressed: playerController.previous,
                              visualDensity: VisualDensity.compact
                            ),
                            GestureDetector(
                              onTap: playerController.togglePlayPause,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(color: AppColors.accentBlue, shape: BoxShape.circle),
                                child: Icon(
                                  playerController.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next_rounded, size: 22, color: AppColors.textSecondary),
                              onPressed: playerController.next,
                              visualDensity: VisualDensity.compact
                            ),
                            IconButton(
                              icon: Icon(
                                playerController.repeatMode == RepeatMode.one
                                    ? Icons.repeat_one_rounded
                                    : Icons.repeat_rounded,
                                size: 18,
                              ),
                              color: playerController.repeatMode == RepeatMode.off
                                  ? AppColors.textDisabled
                                  : AppColors.accentBlue,
                              onPressed: playerController.cycleRepeatMode,
                              visualDensity: VisualDensity.compact
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 36,
                              child: Text(
                                _formatDuration(position),
                                style: const TextStyle(color: AppColors.textDisabled, fontSize: 10),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                ),
                                child: Slider(
                                  value: valueMs,
                                  max: maxMs,
                                  onChanged: track == null
                                      ? null
                                      : (value) => playerController.seek(Duration(milliseconds: value.toInt())),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              child: Text(
                                _formatDuration(duration),
                                style: const TextStyle(color: AppColors.textDisabled, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.queue_music_rounded, size: 20),
                        color: queueOpen ? AppColors.accentBlue : AppColors.textDisabled,
                        onPressed: onToggleQueue,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}