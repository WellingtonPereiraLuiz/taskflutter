import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final ITaskRepository _repository;

  TaskViewModel({ITaskRepository? repository})
      : _repository = repository ?? TaskRepository();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  bool get isEmpty => _tasks.isEmpty;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _setLoading(true);
    _setError(null);
    try {
      final tasks = await _repository.getAllTasks();
      _tasks = tasks;
    } on RepositoryException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Erro inesperado ao carregar tarefas.');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTask({
    required String title,
    required String description,
  }) async {
    if (title.trim().isEmpty) {
      _setError('O título não pode ser vazio.');
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      final newTask = TaskModel(
        title: title.trim(),
        description: description.trim(),
        createdAt: DateTime.now(),
      );
      final created = await _repository.createTask(newTask);
      _tasks.insert(0, created);
      notifyListeners();
      return true;
    } on RepositoryException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erro inesperado ao criar tarefa.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    // Optimistic update
    _tasks[index] = updatedTask;
    notifyListeners();

    try {
      await _repository.updateTask(updatedTask);
    } on RepositoryException catch (e) {
      // Rollback on failure
      _tasks[index] = task;
      _setError(e.message);
    } catch (e) {
      _tasks[index] = task;
      _setError('Erro ao atualizar tarefa.');
    }
  }

  Future<void> deleteTask(int id) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return;

    final removedTask = _tasks[taskIndex];
    // Optimistic removal
    _tasks.removeAt(taskIndex);
    notifyListeners();

    try {
      await _repository.deleteTask(id);
    } on RepositoryException catch (e) {
      // Rollback on failure
      _tasks.insert(taskIndex, removedTask);
      _setError(e.message);
    } catch (e) {
      _tasks.insert(taskIndex, removedTask);
      _setError('Erro ao deletar tarefa.');
    }
  }
}
