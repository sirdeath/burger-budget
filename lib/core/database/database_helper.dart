import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _seedVersionKey = 'seed_db_version';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> get _dbPath async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, AppConstants.dbFileName);
  }

  Future<Database> _initDatabase() async {
    final path = await _dbPath;
    final exists = await File(path).exists();
    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getInt(_seedVersionKey) ?? 0;
    final needsRefresh =
        !exists || storedVersion < AppConstants.seedDbVersion;

    if (needsRefresh) {
      await _copySeedDatabase(path);
      await prefs.setInt(
        _seedVersionKey,
        AppConstants.seedDbVersion,
      );
    }

    return openDatabase(path, readOnly: false);
  }

  Future<void> _copySeedDatabase(String destPath) async {
    final data = await rootBundle.load(AppConstants.seedDbAssetPath);
    final bytes = data.buffer.asUint8List();
    await File(destPath).writeAsBytes(bytes, flush: true);
  }

  Future<void> replaceDatabase(String newDbPath) async {
    await _database?.close();
    _database = null;

    final path = await _dbPath;
    await File(newDbPath).rename(path);

    _database = await openDatabase(path, readOnly: false);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
