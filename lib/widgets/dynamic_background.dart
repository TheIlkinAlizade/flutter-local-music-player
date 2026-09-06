import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../main.dart';

class DynamicBackground extends StatelessWidget {
  final Widget child;

  const DynamicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.background)),
        AnimatedBuilder(
          animation: playerController,
          builder: (context, _) {
            final palette = playerController.currentPalette;
            return Stack(
              children: [
                _glow(palette[0], top: -140, left: -120, size: 460),
                _glow(palette[1], top: -80, right: -160, size: 420),
                _glow(palette[2], bottom: -160, left: 140, size: 480),
              ],
            );
          },
        ),
        child,
      ],
    );
  }

  Widget _glow(Color color, {double? top, double? bottom, double? left, double? right, required double size}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0.0)],
            ),
          ),
        ),
      ),
    );
  }
}