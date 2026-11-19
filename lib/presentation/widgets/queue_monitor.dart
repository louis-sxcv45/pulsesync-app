import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/queue_item.dart';
import '../providers/queue_provider.dart';
import '../resources/colors_manager.dart';
import '../resources/font_manager.dart';
import '../resources/values_manager.dart';

class QueueMonitor extends StatelessWidget {
  const QueueMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    final q = context.watch<QueueProvider>();
    return Container(
      padding: const EdgeInsets.all(AppSize.s12),
      decoration: BoxDecoration(
        color: ColorsManager.surface,
        borderRadius: BorderRadius.circular(AppSize.radius),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SYNC QUEUE MONITOR',
                  style: TextStyle(
                      color: ColorsManager.textMuted,
                      fontSize: 11,
                      letterSpacing: 1.1)),
              Text('${q.openCount} ANTREAN',
                  style: FontManager.label
                      .copyWith(color: ColorsManager.primary)),
            ],
          ),
          const SizedBox(height: AppSize.s8),
          if (q.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSize.s16),
              child: Center(
                  child: Text('Belum ada laporan',
                      style: TextStyle(color: ColorsManager.textMuted))),
            ),
          for (final item in q.items.take(10)) _Tile(item: item),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item});
  final QueueItem item;

  String _hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (item.status) {
      SyncStatus.pending => ('PENDING', ColorsManager.primary),
      SyncStatus.retrying => (
          'RETRY (${item.retryCount}/${AppStrings.maxRetry})',
          ColorsManager.warning
        ),
      SyncStatus.synced => (
          'SYNCED ${_hm(item.syncedAt ?? item.createdAt)}',
          ColorsManager.normal
        ),
      SyncStatus.failed => ('FAILED / DEAD', ColorsManager.critical),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: AppSize.s8),
      padding: const EdgeInsets.all(AppSize.s12),
      decoration: BoxDecoration(
        color: ColorsManager.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.odpId,
                    style: FontManager.monoSmall
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(
                    '${item.signalDbm.toStringAsFixed(1)} dBm • ${item.category}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: ColorsManager.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(6)),
            child: Text(text,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
