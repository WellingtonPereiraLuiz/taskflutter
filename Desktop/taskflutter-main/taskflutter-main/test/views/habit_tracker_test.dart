// test/views/habit_tracker_test.dart
//
// Testes de Widget (Caixa Preta) — Fluxo Completo de Criação de Hábito.
//
// Estratégia:
//   - FakeTaskViewModel com suporte a criação de hábito simulada.
//   - Testa o caminho completo: FAB → modal → preencher → confirmar → lista.
//   - Valida elementos visuais específicos do HabitCard (LinearProgressIndicator,
//     bolinhas dos dias da semana, nome do hábito).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:taskflutter/viewmodels/task_viewmodel.dart';
import 'package:taskflutter/models/task_model.dart';
import 'package:taskflutter/views/home_screen.dart';
import 'package:taskflutter/utils/app_theme.dart';

// ─── Fake ViewModel com suporte a adição de hábito ───────────────────────────

class _HabitCreationViewModel extends ChangeNotifier
    implements TaskViewModel {
  // Estado interno mutável para simular criação
  final List<TaskModel> _habits = [];

  // ── Getters requeridos pela interface ─────────────────────────────────────
  @override List<TaskModel> get tasks => List.unmodifiable(_habits);
  @override List<TaskModel> get displayTasks => const [];
  @override List<TaskModel> get todayTasks => const [];
  @override List<TaskModel> get habitTasks => List.unmodifiable(_habits);
  @override List<TaskModel> get tasksForSelectedDay => const [];
  @override bool get isLoading => false;
  @override bool get isEmpty => _habits.isEmpty;
  @override String? get errorMessage => null;
  @override int get completedCount => 0;
  @override int get pendingCount => 0;
  @override int get currentStreak => 0;
  @override bool get hardMode => false;
  @override int get habitsCompletedToday => 0;
  @override bool get hasOverdueTasks => false;
  @override double get successRate => 0;
  @override DateTime get selectedDay => DateTime.now();
  @override Map<int, int> get weeklyCompletionData => {};
  @override Map<TaskCategory, int> get categoryDistribution => {};

  // ── Métodos ───────────────────────────────────────────────────────────────
  @override Future<void> loadTasks() async {}
  @override Future<void> loadStreak() async {}
  @override Future<void> recordStreakActivity() async {}

  /// Simula a criação de um hábito adicionando-o à lista interna.
  @override
  Future<bool> createTask({
    required String title,
    required String description,
    TaskCategory category = TaskCategory.outro,
    int? durationInMinutes,
    TaskType taskType = TaskType.todo,
  }) async {
    final newHabit = TaskModel(
      id: _habits.length + 1,
      title: title,
      description: description,
      category: category,
      createdAt: DateTime.now(),
      taskType: taskType,
    );
    _habits.add(newHabit);
    notifyListeners();
    return true;
  }

  @override Future<void> toggleTaskCompletion(TaskModel task) async {}
  @override Future<void> deleteTask(int id) async {}
  @override Future<void> toggleHabitDay(TaskModel habit, DateTime day) async {}
  @override void toggleHardMode() {}
  @override void setSelectedDay(DateTime day) {}
  @override void clearError() {}
}

// ─── Helper ──────────────────────────────────────────────────────────────────

Widget _buildTestable(TaskViewModel vm) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: ChangeNotifierProvider<TaskViewModel>.value(
      value: vm,
      child: const HomeScreen(),
    ),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('Habit Tracker — Fluxo de Criação de Hábito', () {
    testWidgets(
      'tela inicia sem hábitos e exibe estado vazio',
      (WidgetTester tester) async {
        final vm = _HabitCreationViewModel();
        await tester.pumpWidget(_buildTestable(vm));
        await tester.pump();

        // Estado inicial vazio
        expect(find.text('Nenhuma missão ainda'), findsOneWidget);
        expect(find.text('Hábitos Diários'), findsNothing);
      },
    );

    testWidgets(
      'abrindo o modal e selecionando "Hábito" mostra formulário de hábito',
      (WidgetTester tester) async {
        final vm = _HabitCreationViewModel();
        await tester.pumpWidget(_buildTestable(vm));
        await tester.pump();

        // Abre o modal via FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Seleciona o tipo "Hábito"
        await tester.tap(find.text('Hábito'));
        await tester.pump();

        // Título do modal deve mudar
        expect(find.text('Novo Hábito'), findsOneWidget);
        // Subtítulo deve mudar
        expect(
          find.text('Crie uma rotina inegociável que se repete todo dia.'),
          findsOneWidget,
        );
        // Botão de confirmação deve ser "Criar Hábito"
        expect(find.text('Criar Hábito'), findsOneWidget);
      },
    );

    testWidgets(
      'preencher título e confirmar cria o hábito na seção "Hábitos Diários"',
      (WidgetTester tester) async {
        final vm = _HabitCreationViewModel();
        await tester.pumpWidget(_buildTestable(vm));
        await tester.pump();

        // Abre o modal
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Seleciona tipo "Hábito"
        await tester.tap(find.text('Hábito'));
        await tester.pump();

        // Preenche o título
        await tester.enterText(
          find.byType(TextFormField).first,
          'Meditar 10 minutos',
        );
        await tester.pump();

        // Confirma
        await tester.tap(find.text('Criar Hábito'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // O hábito deve aparecer na seção correta (o modal fechou)
        expect(find.text('Hábitos Diários'), findsOneWidget);
        // Usa findsAtLeastNWidgets pois o texto pode aparecer no card e/ou no campo
        expect(find.text('Meditar 10 minutos'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'HabitCard exibe LinearProgressIndicator após criação do hábito',
      (WidgetTester tester) async {
        final vm = _HabitCreationViewModel();
        await tester.pumpWidget(_buildTestable(vm));
        await tester.pump();

        // Cria o hábito via modal
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Hábito'));
        await tester.pump();
        await tester.enterText(
          find.byType(TextFormField).first,
          'Beber 2L de água',
        );
        await tester.tap(find.text('Criar Hábito'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Deve haver um LinearProgressIndicator no HabitCard
        expect(find.byType(LinearProgressIndicator), findsWidgets);
      },
    );

    testWidgets(
      'HabitCard exibe o título do hábito criado',
      (WidgetTester tester) async {
        final vm = _HabitCreationViewModel();
        await tester.pumpWidget(_buildTestable(vm));
        await tester.pump();

        // Cria o hábito
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Hábito'));
        await tester.pump();
        await tester.enterText(
          find.byType(TextFormField).first,
          'Ler 30 páginas',
        );
        await tester.tap(find.text('Criar Hábito'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Ler 30 páginas'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'múltiplos hábitos criados aparecem todos na seção',
      (WidgetTester tester) async {
        // Pré-popula o ViewModel diretamente para evitar loop de modal
        final vm = _HabitCreationViewModel();
        await vm.createTask(
          title: 'Acordar cedo',
          description: '',
          taskType: TaskType.habit,
        );
        await vm.createTask(
          title: 'Exercitar-se',
          description: '',
          taskType: TaskType.habit,
        );

        await tester.pumpWidget(_buildTestable(vm));
        await tester.pump();

        // Ambos os hábitos devem estar visíveis
        expect(find.text('Acordar cedo'), findsOneWidget);
        expect(find.text('Exercitar-se'), findsOneWidget);
        expect(find.text('Hábitos Diários'), findsOneWidget);
      },
    );


    testWidgets(
      'modal mostra validação quando título está vazio',
      (WidgetTester tester) async {
        final vm = _HabitCreationViewModel();
        await tester.pumpWidget(_buildTestable(vm));
        await tester.pump();

        // Abre o modal
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Seleciona Hábito
        await tester.tap(find.text('Hábito'));
        await tester.pump();

        // Tenta criar sem preencher o título
        await tester.tap(find.text('Criar Hábito'));
        await tester.pump();

        // Mensagem de validação deve aparecer
        expect(
          find.text('Por favor, insira um título.'),
          findsOneWidget,
        );

        // Nenhum hábito deve ter sido criado
        expect(find.text('Hábitos Diários'), findsNothing);
      },
    );
  });
}
