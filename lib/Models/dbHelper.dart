import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  //results dta
  Map<String, double> gradePoints = {
    'A+': 4.0, 'A': 4.0, 'A-': 3.7,
    'B+': 3.3, 'B': 3.0, 'B-': 2.7,
    'C+': 2.3, 'C': 2.0, 'C-': 1.7,
    'D+': 1.3, 'D': 1.0, 'E': 0.7
  };

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  //initializing db
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gpa_calculator.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Create modules table
    await db.execute('''
      CREATE TABLE modules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        module_name TEXT NOT NULL,
        credit INTEGER NOT NULL,
        result TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // User operations
  Future<int> insertUser(String name) async {
    final db = await database;
    return await db.insert('users', {'name': name});
  }
  //get users form db - for homePage
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }
  //get users form db using id- for ViewPage
  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    var results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }
  //delete users & data form db - for homePage
  Future<int> deleteUser(int id) async {
    final db = await database;
    // Delete user's modules first
    await db.delete('modules', where: 'user_id = ?', whereArgs: [id]);
    // Then delete user
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // module operations
  Future<int> insertModule(int userId, String moduleName, int credit, String result) async {
    final db = await database;
    return await db.insert('modules', {
      'user_id': userId,
      'module_name': moduleName,
      'credit': credit,
      'result': result,
    });
  }
  //get modules using userid form db
  Future<List<Map<String, dynamic>>> getModulesByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'modules',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }
  //get modules using moduleid form db
  Future<Map<String, dynamic>?> getModule(int moduleId) async {
    final db = await database;
    var results = await db.query(
      'modules',
      where: 'id = ?',
      whereArgs: [moduleId],
    );
    return results.isNotEmpty ? results.first : null;
  }
  //update modules using moduleid form db
  Future<int> updateModule(int moduleId, String moduleName, int credit, String result) async {
    final db = await database;
    return await db.update(
      'modules',
      {
        'module_name': moduleName,
        'credit': credit,
        'result': result,
      },
      where: 'id = ?',
      whereArgs: [moduleId],
    );
  }
  //delete modules using moduleid form db
  Future<int> deleteModule(int moduleId) async {
    final db = await database;
    return await db.delete(
      'modules',
      where: 'id = ?',
      whereArgs: [moduleId],
    );
  }

  //get modules count using userid form db
  Future<int> getModuleCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM modules 
      WHERE user_id = ?
    ''', [userId]);
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //get modules credit totcount/sum using userid form db
  Future<int> calculateTotalCredits(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(credit) as total_credits 
      FROM modules 
      WHERE user_id = ?
    ''', [userId]);
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //get gpa using userid form db
  Future<double> calculateGPA(int userId) async {
    final modules = await getModulesByUserId(userId);
    if (modules.isEmpty) return 0.0;

    double totalPoints = 0.0;
    int totalCredits = 0;

    for (var module in modules) {
      int credit = module['credit'] as int;
      String grade = module['result'] as String;
      double gradePoint = gradePoints[grade.toUpperCase()] ?? 0.0;
      
      totalPoints += (credit * gradePoint);
      totalCredits += credit;
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }
  //get status using userid form db
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final moduleCount = await getModuleCount(userId);
    final totalCredits = await calculateTotalCredits(userId);
    final gpa = await calculateGPA(userId);

    return {
      'moduleCount': moduleCount,
      'totalCredits': totalCredits,
      'gpa': gpa,
    };
  }
}