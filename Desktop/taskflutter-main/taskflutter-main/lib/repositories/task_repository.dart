import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/task_model.dart';
import '../services/database_service.dart';

// ─── Interface ───────────────────────────────────────────────────────────────

abstract class ITaskRepository {
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<bool> deleteTask(int id);
  Future<TaskModel?> getTaskById(int id);
}

// ─── Factory ─────────────────────────────────────────────────────────────────

class TaskRepositoryFactory {
  static ITaskRepository create() {
    if (kIsWeb) {
      return InMemoryTaskRepository();
    }
    return SqfliteTaskRepository();
  }
}

// ─── SQLite Implementation (Android / iOS / Desktop) ─────────────────────────

class SqfliteTaskRepository implements ITaskRepository {
  final DatabaseService _databaseService;

  SqfliteTaskRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final maps = await _databaseService.query(
        DatabaseService.tableTask,
        orderBy: 'createdAt DESC',
      );
      return maps.map((map) => TaskModel.fromMap(map)).toList();
    } on Exception catch (e) {
      throw RepositoryException(
        'Falha ao buscar tarefas: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final map = task.toMap()..remove('id');
      final id = await _databaseService.insert(
        DatabaseService.tableTask,
        map,
      );
      return task.copyWith(id: id);
    } on Exception catch (e) {
      throw RepositoryException(
        'Falha ao criar tarefa: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    if (task.id == null) {
      throw const RepositoryException('Tarefa sem ID não pode ser atualizada.');
    }
    try {
      await _databaseService.update(
        DatabaseService.tableTask,
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      return task;
    } on Exception catch (e) {
      throw RepositoryException(
        'Falha ao atualizar tarefa: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<bool> deleteTask(int id) async {
    try {
      final rowsAffected = await _databaseService.delete(
        DatabaseService.tableTask,
        where: 'id = ?',
        whereArgs: [id],
      );
      return rowsAffected > 0;
    } on Exception catch (e) {
      throw RepositoryException(
        'Falha ao deletar tarefa: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<TaskModel?> getTaskById(int id) async {
    try {
      final maps = await _databaseService.query(
        DatabaseService.tableTask,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return TaskModel.fromMap(maps.first);
    } on Exception catch (e) {
      throw RepositoryException(
        'Falha ao buscar tarefa por ID: ${e.toString()}',
        originalException: e,
      );
    }
  }
}

// ─── In-Memory Implementation (Web) ──────────────────────────────────────────

class InMemoryTaskRepository implements ITaskRepository {
  int _nextId = 7;

  final now = DateTime.now();

  late final List<TaskModel> _tasks = () {
    final n = DateTime.now();
    final todayKey =
        '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
    final yesterdayKey = () {
      final y = n.subtract(const Duration(days: 1));
      return '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
    }();

    return [
      // ── Tarefas (todo) ──────────────────────────────────────────
      TaskModel(
        id: 1,
        title: 'Estudar Flutter por 2 horas',
        description:
            'Focar nos conceitos de arquitetura MVVM, Provider e widgets avançados.',
        isCompleted: false,
        createdAt: n.subtract(const Duration(hours: 2)),
        category: TaskCategory.estudo,
        taskType: TaskType.todo,
      ),
      TaskModel(
        id: 2,
        title: 'Entregar o projeto GritTracker',
        description:
            'Revisar o README, tirar prints e submeter o repositório para o professor.',
        isCompleted: true,
        createdAt: n.subtract(const Duration(hours: 1)),
        category: TaskCategory.trabalho,
        taskType: TaskType.todo,
      ),
      TaskModel(
        id: 3,
        title: 'Treino de 45 minutos',
        description: 'Sessão HIIT + core. Sem desculpas.',
        isCompleted: false,
        createdAt: n.subtract(const Duration(minutes: 30)),
        category: TaskCategory.treino,
        taskType: TaskType.todo,
      ),
      // ── Hábitos (habit) ─────────────────────────────────────────
      TaskModel(
        id: 4,
        title: 'Meditação matinal',
        description: '10 minutos de respiração consciente ao acordar.',
        isCompleted: false,
        createdAt: n.subtract(const Duration(days: 3)),
        category: TaskCategory.outro,
        taskType: TaskType.habit,
        weeklyCompletions: [todayKey, yesterdayKey],
      ),
      TaskModel(
        id: 5,
        title: 'Leitura diária',
        description:
            '30 páginas de um livro técnico ou de desenvolvimento pessoal.',
        isCompleted: false,
        createdAt: n.subtract(const Duration(days: 5)),
        category: TaskCategory.estudo,
        taskType: TaskType.habit,
        weeklyCompletions: [todayKey],
      ),
      TaskModel(
        id: 6,
        title: 'Sem redes sociais até 10h',
        description: 'Proteger as primeiras horas do dia para foco profundo.',
        isCompleted: false,
        createdAt: n.subtract(const Duration(days: 7)),
        category: TaskCategory.outro,
        taskType: TaskType.habit,
        weeklyCompletions: [todayKey, yesterdayKey],
      ),
    ];
  }();

  Future<void> _simulateLatency() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    await _simulateLatency();
    return List<TaskModel>.from(_tasks.reversed);
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    await _simulateLatency();
    final newTask = task.copyWith(id: _nextId++);
    _tasks.add(newTask);
    return newTask;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    await _simulateLatency();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      throw RepositoryException('Tarefa não encontrada para atualização.');
    }
    _tasks[index] = task;
    return task;
  }

  @override
  Future<bool> deleteTask(int id) async {
    await _simulateLatency();
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return false;
    _tasks.removeAt(index);
    return true;
  }

  @override
  Future<TaskModel?> getTaskById(int id) async {
    await _simulateLatency();
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class RepositoryException implements Exception {
  final String message;
  final Exception? originalException;

  const RepositoryException(this.message, {this.originalException});

  @override
  String toString() => 'RepositoryException: $message';
}

// ─── Backward-compat alias ───────────────────────────────────────────────────
typedef TaskRepository = SqfliteTaskRepository;
