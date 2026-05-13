import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/app_theme.dart';
import 'viewmodels/task_viewmodel.dart';
import 'views/login_screen.dart';

// ===========================================================================
// ATENÇÃO: Firebase.initializeApp() requer o arquivo firebase_options.dart,
// gerado pelo comando: flutterfire configure
// Se você ainda NÃO configurou o Firebase, o app fará bypass automático
// para a LoginScreen sem crash — o Firebase.initializeApp() está em try/catch.
// Veja lib/services/auth_service.dart para as instruções completas.
// ===========================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tenta inicializar o Firebase — não quebra o app se não estiver configurado.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase não configurado ainda — app roda em modo demo (sem auth real).
  }

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
        home: const LoginScreen(),
      ),
    );
  }
}
