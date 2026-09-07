import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../main.dart';

class DynamicBackground extends StatelessWidget {
  final Widget child;

  const DynamicBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base background
        const ColoredBox(
          color: AppColors.background,
        ),

        // Dynamic artwork glows
        AnimatedBuilder(
          animation: playerController,
          builder: (context, _) {
            final palette = playerController.currentPalette;

            // IMPORTANT: don't assume palette has 3 colors
            if (palette.length < 3) {
              return const SizedBox.shrink();
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                _buildGlow(
                  palette[0],
                  top: -180,
                  left: -180,
                  size: 600,
                ),

                _buildGlow(
                  palette[1],
                  top: -120,
                  right: -200,
                  size: 550,
                ),

                _buildGlow(
                  palette[2],
                  bottom: -220,
                  left: 100,
                  size: 600,
                ),
              ],
            );
          },
        ),

        // Application UI
        child,
      ],
    );
  }

  Widget _buildGlow(
    Color color, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: size,
      height: size,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.5,
              colors: [
                color.withValues(alpha: 0.75),
                color.withValues(alpha: 0.30),
                color.withValues(alpha: 0.0),
              ],
              stops: const [
                0.0,
                0.35,
                1.0,
              ],
            ),
          ),
        ),
      ),
    );
  }
}