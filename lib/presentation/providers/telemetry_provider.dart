import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

import '../../data/services/telemetry_service.dart';
import '../../domain/entities/queue_item.dart';

class TelemetryProvider extends ChangeNotifier {
  TelemetryProvider(this._service);
  final TelemetryService _service;

  StreamSubscription<double>? _sub;
  double value = -18.4;
  final List<double> history = [];

  SignalLevel get level => signalLevelOf(value);

  void start() {
    _sub ??= _service.stream().listen(
      (v) {
        value = v;
        history.add(v);
        if (history.length > 40) history.removeAt(0);
        notifyListeners();
      },
      onError: (Object e, StackTrace st) =>
          dev.log('Telemetry stream error', error: e, stackTrace: st),
    );
  }

  @override
  void dispose() {
    _sub?.cancel(); // lifecycle hygiene: no leaked subscription/timer
    _sub = null;
    super.dispose();
  }
}
