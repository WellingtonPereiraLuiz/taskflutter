import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../services/streak_service.dart';

class TaskViewModel extends ChangeNotifier {
  final ITaskRepository _repository;

  TaskViewModel({ITaskRepository? repository})
      : _repository = repository ?? TaskRepositoryFactory.create();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStreak = 0;
  bool _hardMode = false;
  DateTime _selectedDay = DateTime.now(); // Data selecionada no calendário

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  bool get isEmpty => _tasks.isEmpty;
  int get currentStreak => _currentStreak;
  bool get hardMode => _hardMode;
  DateTime get selectedDay => _selectedDay;

  /// Tarefas filtradas para modo Hard 75 (oculta concluídas).
  List<TaskModel> get displayTasks {
    if (_hardMode) {
      return _tasks.where((t) => !t.isCompleted && t.taskType == TaskType.todo).toList();
    }
    return _tasks.where((t) => t.taskType == TaskType.todo).toList();
  }

  /// Apenas tarefas únicas (tipo todo).
  List<TaskModel> get todayTasks =>
      _tasks.where((t) => t.taskType == TaskType.todo).toList();

  /// Apenas hábitos diários recorrentes.
  List<TaskModel> get habitTasks =>
      _tasks.where((t) => t.taskType == TaskType.habit).toList();

  /// Quantidade de hábitos concluídos hoje.
  int get habitsCompletedToday {
    final todayKey = _dateKey(DateTime.now());
    return habitTasks
        .where((h) => h.weeklyCompletions.contains(todayKey))
        .length;
  }

  /// Tarefas filtradas pelo dia selecionado no calendário.
  List<TaskModel> get tasksForSelectedDay {
    return _tasks.where((t) {
      return t.createdAt.year == _selectedDay.year &&
          t.createdAt.month == _selectedDay.month &&
          t.createdAt.day == _selectedDay.day;
    }).toList();
  }

  /// Verifica se existem tarefas pendentes com mais de 24h (atraso).
  bool get hasOverdueTasks {
    final now = DateTime.now();
    return _tasks.any(
      (t) => !t.isCompleted && now.difference(t.createdAt).inHours >= 24,
    );
  }

  /// Taxa de sucesso (% de tarefas concluídas).
  double get successRate {
    final todos = todayTasks;
    if (todos.isEmpty) return 0;
    return (todos.where((t) => t.isCompleted).length / todos.length) * 100;
  }

  /// Dados para gráfico semanal de tarefas concluídas por dia.
  Map<int, int> get weeklyCompletionData {
    final now = DateTime.now();
    final Map<int, int> data = {};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final weekday = day.weekday; // 1=Mon ... 7=Sun
      final completedOnDay = _tasks.where((t) {
        return t.isCompleted &&
            t.createdAt.year == day.year &&
            t.createdAt.month == day.month &&
            t.createdAt.day == day.day;
      }).length;
      data[weekday] = completedOnDay;
    }
    return data;
  }

  /// Contagem de tarefas por categoria.
  Map<TaskCategory, int> get categoryDistribution {
    final Map<TaskCategory, int> data = {};
    for (final task in _tasks) {
      data[task.category] = (data[task.category] ?? 0) + 1;
    }
    return data;
  }

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

  /// Toggle do modo Hard 75.
  void toggleHardMode() {
    _hardMode = !_hardMode;
    notifyListeners();
  }

  /// Atualiza o dia selecionado no calendário.
  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  /// Carrega o streak atual do SharedPreferences.
  Future<void> loadStreak() async {
    _currentStreak = await StreakService.getCurrentStreak();
    notifyListeners();
  }

  /// Registra atividade de hoje e atualiza streak.
  Future<void> recordStreakActivity() async {
    _currentStreak = await StreakService.recordActivity();
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _setLoading(true);
    _setError(null);
    try {
      final tasks = await _repository.getAllTasks();
      _tasks = tasks;
      // Carrega streak ao carregar tarefas
      await loadStreak();
      await recordStreakActivity();
    } on RepositoryException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Erro inesperado ao carregar tarefas: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTask({
    required String title,
    required String description,
    TaskCategory category = TaskCategory.outro,
    int? durationInMinutes,
    TaskType taskType = TaskType.todo,
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
        category: category,
        durationInMinutes: durationInMinutes,
        taskType: taskType,
      );
      final created = await _repository.createTask(newTask);
      _tasks.insert(0, created);
      notifyListeners();
      return true;
    } on RepositoryException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erro inesperado ao criar tarefa: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Marca/desmarca um hábito como concluído para o dia especificado.
  Future<void> toggleHabitDay(TaskModel habit, DateTime day) async {
    final key = _dateKey(day);
    final completions = List<String>.from(habit.weeklyCompletions);
    if (completions.contains(key)) {
      completions.remove(key);
    } else {
      completions.add(key);
    }
    final updated = habit.copyWith(weeklyCompletions: completions);
    final index = _tasks.indexWhere((t) => t.id == habit.id);
    if (index == -1) return;

    // Optimistic update
    _tasks[index] = updated;
    notifyListeners();

    try {
      await _repository.updateTask(updated);
    } on RepositoryException catch (e) {
      _tasks[index] = habit;
      _setError(e.message);
    } catch (e) {
      _tasks[index] = habit;
      _setError('Erro ao atualizar hábito: ${e.toString()}');
    }
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';


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
      _setError('Erro ao atualizar tarefa: ${e.toString()}');
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
      _setError('Erro ao deletar tarefa: ${e.toString()}');
    }
  }
}
