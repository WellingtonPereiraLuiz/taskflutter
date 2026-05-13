import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_pkg;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  static const String _databaseName = 'grittracker.db';
  static const int _databaseVersion = 4;
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
        createdAt TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'outro',
        durationInMinutes INTEGER,
        taskType TEXT NOT NULL DEFAULT 'todo',
        weeklyCompletions TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Seed tasks (missões únicas)
    final now = DateTime.now();
    await db.insert(tableTask, {
      'title': 'Estudar Flutter por 2 horas',
      'description':
          'Focar nos conceitos de arquitetura MVVM, Provider e widgets avançados.',
      'isCompleted': 0,
      'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
      'category': 'estudo',
      'taskType': 'todo',
      'weeklyCompletions': '',
    });
    await db.insert(tableTask, {
      'title': 'Entregar o projeto GritTracker',
      'description':
          'Revisar o README, tirar prints e submeter o repositório para o professor.',
      'isCompleted': 1,
      'createdAt': now.subtract(const Duration(hours: 1)).toIso8601String(),
      'category': 'trabalho',
      'taskType': 'todo',
      'weeklyCompletions': '',
    });
    await db.insert(tableTask, {
      'title': 'Treino de 45 minutos',
      'description': 'Sessão HIIT + core. Sem desculpas.',
      'isCompleted': 0,
      'createdAt': now.subtract(const Duration(minutes: 30)).toIso8601String(),
      'category': 'treino',
      'taskType': 'todo',
      'weeklyCompletions': '',
    });

    // Seed habits (rotinas diárias)
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final yesterdayKey = () {
      final y = now.subtract(const Duration(days: 1));
      return '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
    }();

    await db.insert(tableTask, {
      'title': 'Meditação matinal',
      'description': '10 minutos de respiração consciente ao acordar.',
      'isCompleted': 0,
      'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
      'category': 'outro',
      'taskType': 'habit',
      'weeklyCompletions': '$todayKey,$yesterdayKey',
    });
    await db.insert(tableTask, {
      'title': 'Leitura diária',
      'description': '30 páginas de um livro técnico ou de desenvolvimento pessoal.',
      'isCompleted': 0,
      'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
      'category': 'estudo',
      'taskType': 'habit',
      'weeklyCompletions': todayKey,
    });
    await db.insert(tableTask, {
      'title': 'Sem redes sociais até 10h',
      'description': 'Proteger as primeiras horas do dia para foco profundo.',
      'isCompleted': 0,
      'createdAt': now.subtract(const Duration(days: 7)).toIso8601String(),
      'category': 'outro',
      'taskType': 'habit',
      'weeklyCompletions':
          '$todayKey,$yesterdayKey',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add category column for v2
      await db.execute(
        "ALTER TABLE $tableTask ADD COLUMN category TEXT NOT NULL DEFAULT 'outro'",
      );
    }
    if (oldVersion < 3) {
      // Add durationInMinutes column for v3
      await db.execute(
        "ALTER TABLE $tableTask ADD COLUMN durationInMinutes INTEGER",
      );
    }
    if (oldVersion < 4) {
      // Add taskType and weeklyCompletions columns for v4 (Habit Tracker)
      await db.execute(
        "ALTER TABLE $tableTask ADD COLUMN taskType TEXT NOT NULL DEFAULT 'todo'",
      );
      await db.execute(
        "ALTER TABLE $tableTask ADD COLUMN weeklyCompletions TEXT NOT NULL DEFAULT ''",
      );
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
