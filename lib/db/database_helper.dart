import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE previous_passwords (
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        password TEXT
      )
    ''');
  }
  Future<int> insertUser(int userId, String password) async {
    final db = await database;
    final Map<String, dynamic> user = {'id': userId, 'password': password};
    return await db.insert('users', user);
  }
  Future<bool> isUserRegistered(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    return result.isNotEmpty;
  }
  Future<void> updateUserPassword(int id, String newPassword) async {
    final db = await database;
    await db.update('users', {'password': newPassword},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertPreviousPassword(int userId, String password) async {
    final db = await database;
    await db.insert('previous_passwords', {'userId': userId, 'password': password});
  }

  Future<List<String>> getPreviousPasswordsByUserId(int userId) async {
    final db = await database;
    final result = await db.query(
      'previous_passwords',
      columns: ['password'],
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return result.map((row) => row['password'] as String).toList();
  }


}
