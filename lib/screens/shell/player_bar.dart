import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/glass_panel.dart';

class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SizedBox(
        height: 88,
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.music_note_rounded, color: AppColors.textDisabled),
              ),
              const SizedBox(width: 12),
              const Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No track playing', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                    SizedBox(height: 2),
                    Text('—', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                        Icon(Icons.shuffle_rounded, size: 18, color: AppColors.textDisabled),
                        const SizedBox(width: 20),
                        Icon(Icons.skip_previous_rounded, size: 22, color: AppColors.textDisabled),
                        const SizedBox(width: 12),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.accentBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.skip_next_rounded, size: 22, color: AppColors.textDisabled),
                        const SizedBox(width: 20),
                        Icon(Icons.repeat_rounded, size: 18, color: AppColors.textDisabled),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      ),
                      child: Slider(value: 0, onChanged: null),
                    ),
                  ],
                ),
              ),
              const Expanded(flex: 2, child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}