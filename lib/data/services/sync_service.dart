import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../../domain/entities/queue_item.dart';
class SyncService {
  final _rand = Random();

  Future<void> send(QueueItem item, NetworkMode mode) async {
    switch (mode) {
      case NetworkMode.online:
        await Future<void>.delayed(const Duration(milliseconds: 400));
        return;
      case NetworkMode.unstable:
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (_rand.nextBool()) throw TimeoutException('Simulated timeout');
        return;
      case NetworkMode.offline:
        throw const SocketException('No connection (blank spot)');
    }
  }
}
