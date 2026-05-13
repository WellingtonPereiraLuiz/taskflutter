import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflutter/models/task_model.dart';
import 'package:taskflutter/repositories/task_repository.dart';
import 'package:taskflutter/viewmodels/task_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTaskRepository extends Mock implements ITaskRepository {}
class FakeTaskModel extends Fake implements TaskModel {}

void main() {
  late MockTaskRepository mockRepository;
  late TaskViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeTaskModel());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockTaskRepository();
    viewModel = TaskViewModel(repository: mockRepository);
  });

  group('TaskViewModel Tests', () {
    test('Estado inicial correto (isLoading false, lista vazia)', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.tasks, isEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    test('Sucesso ao adicionar tarefa (verifica se a lista cresce)', () async {
      final taskToCreate = TaskModel(
        id: 1,
        title: 'Nova Tarefa',
        description: 'Descrição de teste',
        createdAt: DateTime.now(),
        category: TaskCategory.estudo,
        durationInMinutes: 30,
      );

      when(() => mockRepository.createTask(any())).thenAnswer((_) async => taskToCreate);

      final success = await viewModel.createTask(
        title: 'Nova Tarefa',
        description: 'Descrição de teste',
        category: TaskCategory.estudo,
        durationInMinutes: 30,
      );

      expect(success, isTrue);
      expect(viewModel.tasks.length, 1);
      expect(viewModel.tasks.first.title, 'Nova Tarefa');
      expect(viewModel.tasks.first.durationInMinutes, 30);
    });

    test('Lógica do filtro de calendário (tasksForSelectedDay)', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      final taskToday = TaskModel(
        id: 1,
        title: 'Hoje',
        description: '',
        createdAt: today,
        category: TaskCategory.outro,
      );

      final taskTomorrow = TaskModel(
        id: 2,
        title: 'Amanhã',
        description: '',
        createdAt: tomorrow,
        category: TaskCategory.outro,
      );

      when(() => mockRepository.getAllTasks()).thenAnswer((_) async => [taskToday, taskTomorrow]);

      await viewModel.loadTasks();

      // Testa dia atual
      viewModel.setSelectedDay(today);
      expect(viewModel.tasksForSelectedDay.length, 1);
      expect(viewModel.tasksForSelectedDay.first.title, 'Hoje');

      // Testa dia de amanhã
      viewModel.setSelectedDay(tomorrow);
      expect(viewModel.tasksForSelectedDay.length, 1);
      expect(viewModel.tasksForSelectedDay.first.title, 'Amanhã');

      // Testa um dia sem tarefas
      viewModel.setSelectedDay(today.add(const Duration(days: 2)));
      expect(viewModel.tasksForSelectedDay, isEmpty);
    });
  });
}
