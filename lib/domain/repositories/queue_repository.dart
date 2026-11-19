import '../entities/queue_item.dart';

abstract class QueueRepository {
  Future<List<QueueItem>> getAll();

  Future<List<QueueItem>> getPending();

  Future<void> insert(QueueItem item);
  Future<void> update(QueueItem item);
}
