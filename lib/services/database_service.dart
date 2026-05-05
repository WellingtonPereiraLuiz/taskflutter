import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_pkg;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  static const String _databaseName = 'grittracker.db';
  static const int _databaseVersion = 1;
  static const String tableTask = 'tasks';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath;
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      dbPath = path_pkg.join(documentsDir.path, _databaseName);
    } catch (_) {
      dbPath = path_pkg.join(await getDatabasesPath(), _databaseName);
    }

    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTask (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Seed pre-defined tasks
    final now = DateTime.now();
    await db.insert(tableTask, {
      'title': 'Estudar Flutter por 2 horas',
      'description':
          'Focar nos conceitos de arquitetura MVVM, Provider e widgets avançados.',
      'isCompleted': 0,
      'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
    });
    await db.insert(tableTask, {
      'title': 'Entregar o projeto GritTracker',
      'description':
          'Revisar o README, tirar prints e submeter o repositório para o professor.',
      'isCompleted': 1,
      'createdAt': now.subtract(const Duration(hours: 1)).toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS $tableTask');
      await _onCreate(db, newVersion);
    }
  }

  // Simulate network latency as per architecture requirement
  Future<void> _simulateLatency() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    await _simulateLatency();
    final db = await database;
    return await db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    await _simulateLatency();
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await _simulateLatency();
    final db = await database;
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await _simulateLatency();
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
