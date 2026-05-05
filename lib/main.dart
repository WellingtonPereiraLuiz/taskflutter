import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'viewmodels/task_viewmodel.dart';
import 'views/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GritTrackerApp());
}

class GritTrackerApp extends StatelessWidget {
  const GritTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskViewModel>(
          create: (_) => TaskViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'GritTracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
