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
      version: 1,
      onCreate: _onCreate,
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
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
