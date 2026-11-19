import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/queue_item.dart';
import '../providers/telemetry_provider.dart';
import '../resources/colors_manager.dart';
import '../resources/font_manager.dart';
import '../resources/values_manager.dart';

class TelemetryCard extends StatelessWidget {
  const TelemetryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TelemetryProvider>();
    final color = ColorsManager.forLevel(t.level);
    final label = switch (t.level) {
      SignalLevel.normal => 'NORMAL SIGNAL',
      SignalLevel.warning => 'WARNING / MARGINAL',
      SignalLevel.critical => 'CRITICAL LOSS DETECTED',
    };

    return Container(
      padding: const EdgeInsets.all(AppSize.s16),
      decoration: BoxDecoration(
        color: ColorsManager.surface,
        borderRadius: BorderRadius.circular(AppSize.radius),
        border: Border.all(color: ColorsManager.border),
      ),
      child: Column(
        children: [
          const Text('OPTICAL TELEMETRY FEED',
              style: TextStyle(
                  color: ColorsManager.textMuted,
                  fontSize: 11,
                  letterSpacing: 1.2)),
          const SizedBox(height: AppSize.s8),
          RepaintBoundary(
            child: SizedBox(
              height: AppSize.gaugeHeight,
              width: double.infinity,
              child: CustomPaint(
                painter: _GaugePainter(t.value, color),
                child: Align(
                  alignment: const Alignment(0, 0.7),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                        text: t.value.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 38, fontWeight: FontWeight.w800)),
                    const TextSpan(
                        text: ' dBm',
                        style: TextStyle(color: ColorsManager.textMuted)),
                  ])),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSize.s8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color),
            ),
            child: Text('STATUS: $label',
                style: FontManager.label.copyWith(color: color)),
          ),
          const SizedBox(height: AppSize.s12),
          RepaintBoundary(
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: CustomPaint(painter: _SparkPainter(t.history)),
            ),
          ),
          const Text('Live Stream: Periodic 800ms emisi sensor',
              style: TextStyle(color: ColorsManager.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value, this.color);
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final r = min(size.width / 2, size.height) * 0.85;
    final rect = Rect.fromCircle(center: center, radius: r);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = ColorsManager.border;
    canvas.drawArc(rect, pi, pi, false, track);
    final progress = ((value + 35) / 25).clamp(0.0, 1.0);
    canvas.drawArc(rect, pi, pi * progress, false, track..color = color);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.color != color;
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.data);
  final List<double> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height * (1 - ((data[i] + 35) / 25).clamp(0.0, 1.0));
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = ColorsManager.primary);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => true;
}
