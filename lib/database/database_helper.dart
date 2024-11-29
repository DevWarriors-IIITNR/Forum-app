import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE subjects (
        id $idType,
        name $textType,
        totalLectures $intType,
        attendedLectures $intType
      )
    ''');
  }

  Future<int> insertSubject(Map<String, dynamic> subject) async {
    final db = await instance.database;
    return db.insert('subjects', subject);
  }

  Future<List<Map<String, dynamic>>> fetchSubjects() async {
    final db = await instance.database;
    return db.query('subjects');
  }

  Future<int> updateSubject(Map<String, dynamic> subject, int id) async {
    final db = await instance.database;
    return db.update('subjects', subject, where: 'id = ?', whereArgs: [id]);
  }
}
