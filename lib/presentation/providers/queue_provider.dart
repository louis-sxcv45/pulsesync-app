import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/services/sync_service.dart';
import '../../domain/entities/queue_item.dart';
import '../../domain/repositories/queue_repository.dart';
import '../resources/values_manager.dart';

class QueueProvider extends ChangeNotifier {
  QueueProvider(this._repo, this._sync);

  final QueueRepository _repo;
  final SyncService _sync;
  final _rand = Random();

  List<QueueItem> items = [];
  NetworkMode mode = NetworkMode.online;
  String? error;

  bool _draining = false;
  bool _disposed = false;

  int get openCount => items.where((i) => i.isOpen).length;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> init() async {
    try {
      items = await _repo.getAll();
      _notify();
      unawaited(drain());
    } catch (e, st) {
      dev.log('Failed to load queue', error: e, stackTrace: st);
      error = 'Gagal memuat antrean lokal';
      _notify();
    }
  }

  Future<void> setMode(NetworkMode m) async {
    if (m == mode) return;
    mode = m;
    _notify();
    if (m != NetworkMode.offline) await drain();
  }

  Future<void> add({
    required String odpId,
    required double signalDbm,
    required String category,
    required String note,
  }) async {
    final item = QueueItem(
      id: const Uuid().v4(),
      odpId: odpId,
      signalDbm: signalDbm,
      category: category,
      note: note,
      status: SyncStatus.pending,
      retryCount: 0,
      createdAt: DateTime.now(),
    );
    items = [item, ...items];
    _notify();
    try {
      await _repo.insert(item);
    } catch (e, st) {
      dev.log('Insert failed', error: e, stackTrace: st);
      items = items.where((i) => i.id != item.id).toList();
      error = 'Gagal menyimpan laporan ${item.odpId}';
      _notify();
      return;
    }
    unawaited(drain());
  }

  void clearError() {
    error = null;
    _notify();
  }

  Future<void> drain() async {
    if (_draining || mode == NetworkMode.offline || _disposed) return;
    _draining = true;
    try {
      for (final item in await _repo.getPending()) {
        if (_disposed || mode == NetworkMode.offline) break;
        await _process(item);
      }
    } catch (e, st) {
      dev.log('Drain failed', error: e, stackTrace: st);
    } finally {
      _draining = false;
    }
    if (!_disposed && mode != NetworkMode.offline) {
      final left = await _repo.getPending();
      if (left.isNotEmpty) unawaited(drain());
    }
  }

  Future<void> _process(QueueItem item) async {
    var current = item;
    while (current.retryCount < AppStrings.maxRetry) {
      if (_disposed || mode == NetworkMode.offline) return; // keep pending
      try {
        await _sync.send(current, mode);
        await _save(current.copyWith(
            status: SyncStatus.synced, syncedAt: DateTime.now()));
        return;
      } catch (e, st) {
        final attempt = current.retryCount + 1;
        dev.log('Sync attempt $attempt failed for ${current.odpId}',
            error: e, stackTrace: st);
        if (attempt >= AppStrings.maxRetry) {
          await _save(
              current.copyWith(status: SyncStatus.failed, retryCount: attempt));
          return;
        }
        current =
            current.copyWith(status: SyncStatus.retrying, retryCount: attempt);
        await _save(current);
        final delayMs = 1000 * pow(2, attempt - 1).toInt() + _rand.nextInt(250);
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
    }
  }

  Future<void> _save(QueueItem updated) async {
    items = [for (final i in items) i.id == updated.id ? updated : i];
    _notify();
    await _repo.update(updated);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
