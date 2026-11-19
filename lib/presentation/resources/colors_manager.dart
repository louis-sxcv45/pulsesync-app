import 'package:flutter/material.dart';

import '../../domain/entities/queue_item.dart';

class ColorsManager {
  static const bg = Color(0xFF0B1220);
  static const surface = Color(0xFF111A2E);
  static const surfaceAlt = Color(0xFF16213A);
  static const border = Color(0xFF22304F);
  static const primary = Color(0xFF0284C7);
  static const normal = Color(0xFF10B981); // emerald
  static const warning = Color(0xFFF59E0B); // amber
  static const critical = Color(0xFFF43F5E); // rose
  static const textPrimary = Color(0xFFF1F5F9);
  static const textMuted = Color(0xFF94A3B8);

  static Color forLevel(SignalLevel l) => switch (l) {
        SignalLevel.normal => normal,
        SignalLevel.warning => warning,
        SignalLevel.critical => critical,
      };

  static Color forNetwork(NetworkMode m) => switch (m) {
        NetworkMode.online => normal,
        NetworkMode.unstable => warning,
        NetworkMode.offline => critical,
      };
}
