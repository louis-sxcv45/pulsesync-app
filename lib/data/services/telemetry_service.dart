import 'dart:async';
import 'dart:math';

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
          v += (_rand.nextDouble() - 0.5) * 4;
          v += (-20.0 - v) * 0.05;
          if (_rand.nextInt(15) == 0) v -= 3 + _rand.nextDouble() * 6;
          v = v.clamp(-35.0, -10.0).toDouble();
          controller.add(double.parse(v.toStringAsFixed(1)));
        });
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }
}
