import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class SQLiteDatabase {
  static Future<Database> getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'chatNova.db'));
  }

  static Future<void> createTable(String sqlQuery) async {
    final db = await SQLiteDatabase.getDatabase();
    db.execute(sqlQuery);
  }

  static Future<void> insertData(
      String table, Map<String, Object?> data) async {
    final db = await SQLiteDatabase.getDatabase();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> readData(String table) async {
    final db = await SQLiteDatabase.getDatabase();
    db.query(table);
  }
}
