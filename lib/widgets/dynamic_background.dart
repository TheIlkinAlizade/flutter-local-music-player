import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../main.dart';

class DynamicBackground extends StatefulWidget {
  final Widget child;

  const DynamicBackground({
    super.key,
    required this.child,
  });

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(
          color: AppColors.background,
        ),

        AnimatedBuilder(
          animation: Listenable.merge([
            _animationController,
            playerController,
          ]),
          builder: (context, _) {
            final palette = playerController.currentPalette;

            if (palette.length < 3) {
              return const SizedBox.shrink();
            }

            final t = _animationController.value;

            // Smooth floating movement
            final movement1 = math.sin(t * math.pi * 2);
            final movement2 = math.sin(t * math.pi * 2 + 1.8);
            final movement3 = math.sin(t * math.pi * 2 + 3.5);

            return Stack(
              fit: StackFit.expand,
              children: [
                _buildGlow(
                  palette[0],
                  top: -180,
                  left: -180,
                  size: 600,
                  offset: Offset(
                    movement1 * 100,
                    movement2 * 70,
                  ),
                ),

                _buildGlow(
                  palette[1],
                  top: -120,
                  right: -200,
                  size: 550,
                  offset: Offset(
                    movement2 * 120,
                    movement3 * 80,
                  ),
                ),

                _buildGlow(
                  palette[2],
                  bottom: -220,
                  left: 100,
                  size: 600,
                  offset: Offset(
                    movement3 * 100,
                    movement1 * 90,
                  ),
                ),
              ],
            );
          },
        ),

        widget.child,
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
    required Offset offset,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: size,
      height: size,
      child: Transform.translate(
        offset: offset,
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
      ),
    );
  }
}