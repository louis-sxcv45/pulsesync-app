import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _dbName = 'pulsesync.db';
  static const String tableName = 'queue_items';
  static const int _dbVersion = 1;

  Future<void> createTables(Database database) async {
    await database.execute(
      """
        CREATE TABLE $tableName (id TEXT PRIMARY KEY,
        odp_id TEXT NOT NULL,
        signal_dbm REAL NOT NULL,
        category TEXT NOT NULL,
        note TEXT NOT NULL,
        status TEXT NOT NULL,
        retry_count INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        synced_at INTEGER
        )
      """
    );
  }

  Future<Database> _initializeDatabase() async {
    return openDatabase(
      _dbName,
      version: _dbVersion,
      onCreate: (Database database, int version) async {
        await createTables(database);
      }
    );
  }

  Future<Database> get database async {
    return _initializeDatabase();
  }
}