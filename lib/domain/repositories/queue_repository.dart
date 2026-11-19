import '../entities/queue_item.dart';

abstract class QueueRepository {
  /// Newest first (for display).
  Future<List<QueueItem>> getAll();

  /// Pending/retrying only, oldest first (FIFO).
  Future<List<QueueItem>> getPending();

  Future<void> insert(QueueItem item);
  Future<void> update(QueueItem item);
}
