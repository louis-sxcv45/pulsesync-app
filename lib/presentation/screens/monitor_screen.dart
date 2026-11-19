import 'package:flutter/material.dart';

import '../resources/font_manager.dart';
import '../resources/values_manager.dart';
import '../widgets/telemetry_card.dart';

class MonitorScreen extends StatelessWidget {
  const MonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSize.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PulseSync Monitor', style: FontManager.title),
              SizedBox(height: AppSize.s16),
              TelemetryCard(),
            ],
          ),
        ),
      ),
    );
  }
}