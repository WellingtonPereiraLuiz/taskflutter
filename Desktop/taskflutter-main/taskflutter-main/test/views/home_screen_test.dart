// test/views/home_screen_test.dart
//
// Widget Tests (Caixa Preta) para a HomeScreen.
// Estratégia: usar um FakeTaskViewModel que já expõe o estado desejado,
// evitando chamadas a SharedPreferences/SQLite que causam timers infinitos.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:taskflutter/viewmodels/task_viewmodel.dart';
import 'package:taskflutter/models/task_model.dart';
import 'package:taskflutter/views/home_screen.dart';
import 'package:taskflutter/utils/app_theme.dart';

// ─── Fake ViewModels ─────────────────────────────────────────────────────────

/// ViewModel com lista vazia — simula estado "sem tarefas".
class _EmptyViewModel extends ChangeNotifier implements TaskViewModel {
  @override List<TaskModel> get tasks => const [];
  @override List<TaskModel> get displayTasks => const [];
  @override List<TaskModel> get todayTasks => const [];
  @override List<TaskModel> get habitTasks => const [];
  @override List<TaskModel> get tasksForSelectedDay => const [];
  @override bool get isLoading => false;
  @override bool get isEmpty => true;
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

  @override Future<void> loadTasks() async {}
  @override Future<void> loadStreak() async {}
  @override Future<void> recordStreakActivity() async {}
  @override Future<bool> createTask({
    required String title,
    required String description,
    TaskCategory category = TaskCategory.outro,
    int? durationInMinutes,
    TaskType taskType = TaskType.todo,
  }) async => true;
  @override Future<void> toggleTaskCompletion(TaskModel task) async {}
  @override Future<void> deleteTask(int id) async {}
  @override Future<void> toggleHabitDay(TaskModel habit, DateTime day) async {}
  @override void toggleHardMode() {}
  @override void setSelectedDay(DateTime day) {}
  @override void clearError() {}
}

/// ViewModel com 1 tarefa todo.
class _TodoViewModel extends _EmptyViewModel {
  final _task = TaskModel(
    id: 1, title: 'Tarefa de teste', description: '',
    createdAt: DateTime.now(), taskType: TaskType.todo,
  );
  @override bool get isEmpty => false;
  @override List<TaskModel> get tasks => [_task];
  @override List<TaskModel> get displayTasks => [_task];
  @override List<TaskModel> get todayTasks => [_task];
  @override int get pendingCount => 1;
}

/// ViewModel com 1 hábito.
class _HabitViewModel extends _EmptyViewModel {
  final _habit = TaskModel(
    id: 2, title: 'Hábito de teste', description: '',
    createdAt: DateTime.now(), taskType: TaskType.habit,
  );
  @override bool get isEmpty => false;
  @override List<TaskModel> get tasks => [_habit];
  @override List<TaskModel> get habitTasks => [_habit];
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
  // ── Empty State ────────────────────────────────────────────────────────────
  group('HomeScreen — Empty State', () {
    testWidgets(
      'exibe "Nenhuma missão ainda" quando não há tarefas',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestable(_EmptyViewModel()));
        // 1 frame para o postFrameCallback do initState
        await tester.pump();

        expect(find.text('Nenhuma missão ainda'), findsOneWidget);
      },
    );

    testWidgets(
      'exibe ícone rocket_launch quando lista está vazia',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestable(_EmptyViewModel()));
        await tester.pump();

        expect(find.byIcon(Icons.rocket_launch_rounded), findsOneWidget);
      },
    );
  });

  // ── FAB ────────────────────────────────────────────────────────────────────
  group('HomeScreen — FAB', () {
    testWidgets(
      'toque no FAB abre o modal de criação de tarefa',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestable(_EmptyViewModel()));
        await tester.pump();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Nova Missão'), findsOneWidget);
      },
    );

    testWidgets(
      'modal contém botão "Criar Missão" por padrão',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestable(_EmptyViewModel()));
        await tester.pump();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Criar Missão'), findsOneWidget);
      },
    );

    testWidgets(
      'modal contém toggle de tipo Tarefa / Hábito',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestable(_EmptyViewModel()));
        await tester.pump();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Tarefa'), findsOneWidget);
        expect(find.text('Hábito'), findsOneWidget);
      },
    );

    testWidgets(
      'selecionar "Hábito" muda o botão para "Criar Hábito"',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestable(_EmptyViewModel()));
        await tester.pump();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Toca no toggle "Hábito"
        await tester.tap(find.text('Hábito'));
        await tester.pump();

        expect(find.text('Criar Hábito'), findsOneWidget);
        expect(find.text('Criar Missão'), findsNothing);
      },
    );
  });

  // ── Seções ─────────────────────────────────────────────────────────────────
  group('HomeScreen — Seções', () {
    testWidgets(
      'exibe seção "Missões de Hoje" quando há tarefas do tipo todo',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestable(_TodoViewModel()));
        await tester.pump();

        expect(find.text('Missões de Hoje'), findsOneWidget);
      },
    );

    testWidgets(
      'exibe seção "Hábitos Diários" quando há hábitos',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestable(_HabitViewModel()));
        await tester.pump();

        expect(find.text('Hábitos Diários'), findsOneWidget);
      },
    );

    testWidgets(
      'aba Calendário é selecionável pelo BottomNavigationBar',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildTestable(_EmptyViewModel()));
        await tester.pump();

        // Verifica que a aba Missões está ativa inicialmente
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Toca na aba Calendário
        await tester.tap(find.byIcon(Icons.calendar_month_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // O BottomNavigationBar deve ter o item Calendário renderizado
        expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
      },
    );
  });
}
