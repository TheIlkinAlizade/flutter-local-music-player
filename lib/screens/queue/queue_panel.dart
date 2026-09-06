import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../main.dart';
import '../../widgets/glass_panel.dart';
import '../library/widgets/cover_art_thumb.dart';

class QueuePanel extends StatelessWidget {
  final VoidCallback onClose;

  const QueuePanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 12, bottom: 12, left: 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: playerController,
          builder: (context, _) {
            final current = playerController.currentTrack;
            final upcoming = playerController.upcoming;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Queue', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                      onPressed: onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (current != null) ...[
                  const Text('NOW PLAYING', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CoverArtThumb(artPath: current.artPath, size: 40, borderRadius: BorderRadius.circular(6)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(current.track.title, style: const TextStyle(color: AppColors.accentBlue, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(current.track.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                const Text('NEXT UP', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Expanded(
                  child: upcoming.isEmpty
                      ? const Center(
                          child: Text('Nothing queued next', style: TextStyle(color: AppColors.textDisabled, fontSize: 12)),
                        )
                      : ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          itemCount: upcoming.length,
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) newIndex -= 1;
                            playerController.reorderUpcoming(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final item = upcoming[index];
                            return Padding(
                              key: ValueKey(index),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(Icons.drag_indicator_rounded, size: 16, color: AppColors.textDisabled),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => playerController.playUpcomingAt(index),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Row(
                                        children: [
                                          CoverArtThumb(artPath: item.artPath, size: 32, borderRadius: BorderRadius.circular(6)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(item.track.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                Text(item.track.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textDisabled),
                                    onPressed: () => playerController.removeUpcomingAt(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}