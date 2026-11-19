import 'dart:async';
import 'dart:math';

/// Simulated optical power meter. Emits a dBm reading every 800 ms.
class TelemetryService {
  static const interval = Duration(milliseconds: 800);
  final _rand = Random();

  Stream<double> stream() {
    late final StreamController<double> controller;
    Timer? timer;
    var v = -18.0;

    controller = StreamController<double>(
      onListen: () {
        timer = Timer.periodic(interval, (_) {
          v += (_rand.nextDouble() - 0.5) * 4; // random walk
          v += (-20.0 - v) * 0.05; // mean reversion
          if (_rand.nextInt(15) == 0) v -= 3 + _rand.nextDouble() * 6; // dip
          v = v.clamp(-35.0, -10.0).toDouble();
          controller.add(double.parse(v.toStringAsFixed(1)));
        });
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }
}
