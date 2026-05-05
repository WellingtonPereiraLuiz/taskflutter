import '../models/task_model.dart';
import '../services/database_service.dart';

abstract class ITaskRepository {
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<bool> deleteTask(int id);
  Future<TaskModel?> getTaskById(int id);
}

class TaskRepository implements ITaskRepository {
  final DatabaseService _databaseService;

  TaskRepository({DatabaseService? databaseService})
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

class RepositoryException implements Exception {
  final String message;
  final Exception? originalException;

  const RepositoryException(this.message, {this.originalException});

  @override
  String toString() => 'RepositoryException: $message';
}
