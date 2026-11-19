import 'package:pulsesync/data/local/app_database.dart' show AppDatabase;
import 'package:pulsesync/domain/entities/queue_item.dart';
import 'package:pulsesync/domain/repositories/queue_repository.dart';
import 'package:sqflite/sqflite.dart';

class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl(this._appDb);
  final AppDatabase _appDb;

  @override
  Future<List<QueueItem>> getAll() async {
    final db = await _appDb.database;
    final rows = await db.query(
      AppDatabase.tableName,
      orderBy: 'created_at DESC',
    );
    return rows.map(QueueItem.fromMap).toList();
  }

  @override
  Future<List<QueueItem>> getPending() async {
    final db = await _appDb.database;
    final rows = await db.query(
      AppDatabase.tableName,
      where: "status IN ('pending','retrying')",
      orderBy: 'created_at ASC',
    );
    return rows.map(QueueItem.fromMap).toList();
  }

  @override
  Future<void> insert(QueueItem item) async {
    final db = await _appDb.database;
    await db.insert(
      AppDatabase.tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<void> update(QueueItem item) async {
    final db = await _appDb.database;
    await db.update(
      AppDatabase.tableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
}