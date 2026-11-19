import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/queue_item.dart';
import '../providers/queue_provider.dart';

class NetworkToggle extends StatelessWidget {
  const NetworkToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.select<QueueProvider, NetworkMode>((q) => q.mode);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<NetworkMode>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: NetworkMode.online, label: Text('Online')),
          ButtonSegment(value: NetworkMode.unstable, label: Text('Unstable')),
          ButtonSegment(value: NetworkMode.offline, label: Text('Offline')),
        ],
        selected: {mode},
        onSelectionChanged: (s) => context.read<QueueProvider>().setMode(s.first),
      ),
    );
  }
}
