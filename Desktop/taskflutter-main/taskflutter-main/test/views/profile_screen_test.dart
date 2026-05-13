import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflutter/views/profile_screen.dart';
import 'package:taskflutter/viewmodels/task_viewmodel.dart';
import 'package:taskflutter/repositories/task_repository.dart';
import 'package:taskflutter/models/task_model.dart';

// Fake implementation to provide TaskViewModel
class FakeTaskRepository implements ITaskRepository {
  @override
  Future<List<TaskModel>> getAllTasks() async => [];
  @override
  Future<void> saveTask(TaskModel task) async {}
  @override
  Future<TaskModel> createTask(TaskModel task) async => task;
  @override
  Future<TaskModel?> getTaskById(int id) async => null;
  @override
  Future<TaskModel> updateTask(TaskModel task) async => task;
  @override
  Future<bool> deleteTask(int id) async => true;
  @override
  Future<void> clearAll() async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'user_name': 'Herói', 'hard_mode': false});
  });

  Widget createTestableProfileScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskViewModel(repository: FakeTaskRepository())),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  testWidgets('ProfileScreen renderiza o nome inicial e aceita input', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableProfileScreen());
    await tester.pumpAndSettle();

    // Verifica se o campo de texto tem o nome
    expect(find.text('Herói'), findsOneWidget);

    // Entra texto novo
    await tester.enterText(find.byType(TextField).first, 'Super Herói');
    await tester.pumpAndSettle();

    expect(find.text('Super Herói'), findsOneWidget);
  });

  testWidgets('ProfileScreen renderiza o botão de avatar', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableProfileScreen());
    await tester.pumpAndSettle();

    // Deve achar o ícone de pessoa e o botão de câmera
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
  });
}
