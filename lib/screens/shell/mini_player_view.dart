import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart' hide RepeatMode;

import '../../core/theme/app_colors.dart';
import '../../main.dart';

class MiniPlayerView extends StatelessWidget {
  final VoidCallback onExpand;

  const MiniPlayerView({super.key, required this.onExpand});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: playerController,
      builder: (context, _) {
        final track = playerController.currentTrack;
        final position = playerController.position;
        final duration = playerController.duration ?? Duration.zero;
        final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
        final valueMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

        return Stack(
          fit: StackFit.expand,
          children: [
            if (track?.artPath != null)
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
                child: Image.file(File(track!.artPath!), fit: BoxFit.cover),
              )
            else
              const ColoredBox(color: AppColors.background),
            Positioned.fill(child: ColoredBox(color: Colors.black.withValues(alpha: 0.38))),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_full_rounded, color: Colors.white70, size: 20),
                          onPressed: onExpand,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      track?.track.title ?? 'No track playing',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      track?.track.artist ?? '—',
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            _formatDuration(position),
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.white,
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
                          width: 40,
                          child: Text(
                            _formatDuration(duration),
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 30),
                          onPressed: playerController.previous,
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: playerController.togglePlayPause,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              playerController.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 30),
                          onPressed: playerController.next,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}