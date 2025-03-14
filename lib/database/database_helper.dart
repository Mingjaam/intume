import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "diary.db";
  static const _databaseVersion = 1;

  static const table = 'diaries';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnContent = 'content';
  static const columnCreatedAt = 'created_at';

  // 싱글톤 패턴 구현
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL
      )
    ''');
  }

  // CRUD 작업을 위한 메서드들
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table, orderBy: "$columnCreatedAt DESC");
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(
      table, 
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // 특정 날짜 범위의 일기를 불러오는 메소드
  Future<List<Map<String, dynamic>>> getDiariesByDateRange(DateTime start, DateTime end) async {
    final db = await instance.database;
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();
    
    return await db.query(
      table,
      where: '$columnCreatedAt BETWEEN ? AND ?',
      whereArgs: [startStr, endStr],
    );
  }
} 