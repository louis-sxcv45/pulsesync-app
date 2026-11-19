import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/queue_item.dart';
import '../providers/queue_provider.dart';
import '../resources/assets_image_icon.dart';
import '../resources/colors_manager.dart';
import '../resources/font_manager.dart';
import '../resources/values_manager.dart';
import '../widgets/anomaly_bottom_sheet.dart';
import '../widgets/queue_monitor.dart';
import '../widgets/telemetry_card.dart';

class MonitorScreen extends StatelessWidget {
  const MonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Surface persistence errors explicitly (no silent failures).
    context.select<QueueProvider, String?>((q) => q.error);
    final error = context.read<QueueProvider>().error;
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
        context.read<QueueProvider>().clearError();
      });
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSize.s16),
          children: [
            const _Header(),
            const SizedBox(height: AppSize.s12),
            const TelemetryCard(),
            const SizedBox(height: AppSize.s12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              onPressed: () => showAnomalySheet(context),
              icon: const Icon(IconManager.add),
              label: const Text('CATAT ANOMALI ODP BARU'),
            ),
            const SizedBox(height: AppSize.s12),
            const QueueMonitor(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final mode = context.select<QueueProvider, NetworkMode>((q) => q.mode);
    final color = ColorsManager.forNetwork(mode);
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: AppSize.s8),
        const Text('PulseSync Monitor', style: FontManager.title),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(6)),
          child: Text(mode.name.toUpperCase(),
              style: FontManager.label.copyWith(color: color)),
        ),
      ],
    );
  }
}
