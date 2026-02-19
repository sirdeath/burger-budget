import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabaseHelper {
  UserDatabaseHelper._();
  static final UserDatabaseHelper instance = UserDatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'user_data.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        main_item_id TEXT NOT NULL,
        side_item_id TEXT,
        drink_item_id TEXT,
        created_at TEXT NOT NULL,
        UNIQUE(main_item_id, side_item_id, drink_item_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE order_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        main_item_id TEXT NOT NULL,
        side_item_id TEXT,
        drink_item_id TEXT,
        total_price INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_favorites_main '
      'ON favorites(main_item_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_history_created '
      'ON order_history(created_at DESC)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE order_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          main_item_id TEXT NOT NULL,
          side_item_id TEXT,
          drink_item_id TEXT,
          total_price INTEGER NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await _createIndexes(db);
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
