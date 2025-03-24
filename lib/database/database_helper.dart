import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "diary.db";
  static const _databaseVersion = 6;

  static const table = 'diaries';

  static const columnId = 'id';
  static const columnContent = 'content';
  static const columnTag = 'tag';
  static const columnCreatedAt = 'created_at';
  static const columnImagePaths = 'image_paths';

  static const tagTable = 'tags';
  static const columnTagId = 'id';
  static const columnTagName = 'name';
  static const columnTagColor = 'color';
  static const columnTagCreatedAt = 'created_at';
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
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnContent TEXT NOT NULL,
        $columnTag TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnImagePaths TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE $tagTable (
        $columnTagId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTagName TEXT NOT NULL UNIQUE,
        $columnTagColor TEXT NOT NULL,
        $columnTagCreatedAt TEXT NOT NULL
      )
    ''');

    await db.insert(tagTable, {
      columnTagName: 'MY',
      columnTagColor: 'FFFFD700',
      columnTagCreatedAt: DateTime.now().toIso8601String(),
    });
    await db.insert(tagTable, {
      columnTagName: '운동일지',
      columnTagColor: 'FF1DF3EC',
      columnTagCreatedAt: DateTime.now().toIso8601String(),
    });
    await db.insert(tagTable, {
      columnTagName: '영화일지',
      columnTagColor: 'FFF65858',
      columnTagCreatedAt: DateTime.now().toIso8601String(),
    });
    await db.insert(tagTable, {
      columnTagName: 'instagram',
      columnTagColor: 'FFF36DF5',
      columnTagCreatedAt: DateTime.now().toIso8601String(),
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE $tagTable (
          $columnTagId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnTagName TEXT NOT NULL UNIQUE,
          $columnTagColor TEXT NOT NULL,
          $columnTagCreatedAt TEXT NOT NULL
        )
      ''');

      await db.insert(tagTable, {
        columnTagName: 'MY',
        columnTagColor: 'FFFFD700',
        columnTagCreatedAt: DateTime.now().toIso8601String(),
      });
      await db.insert(tagTable, {
        columnTagName: '운동일지',
        columnTagColor: 'FF1DF3EC',
        columnTagCreatedAt: DateTime.now().toIso8601String(),
      });
      await db.insert(tagTable, {
        columnTagName: '영화일지',
        columnTagColor: 'FFF65858',
        columnTagCreatedAt: DateTime.now().toIso8601String(),
      });
      await db.insert(tagTable, {
        columnTagName: 'instagram',
        columnTagColor: 'FFF36DF5',
        columnTagCreatedAt: DateTime.now().toIso8601String(),
      });
    }
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

  Future<List<Map<String, dynamic>>> getAllTags() async {
    Database db = await instance.database;
    return await db.query(tagTable, orderBy: '$columnTagCreatedAt ASC');
  }

  Future<int> insertTag(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tagTable, row);
  }

  Future<int> deleteTag(String tagName) async {
    Database db = await instance.database;
    return await db.delete(
      tagTable,
      where: '$columnTagName = ?',
      whereArgs: [tagName],
    );
  }

  Future<bool> isTagExists(String tagName) async {
    Database db = await instance.database;
    var result = await db.query(
      tagTable,
      where: '$columnTagName = ?',
      whereArgs: [tagName],
    );
    return result.isNotEmpty;
  }
} 