import 'package:flutter/material.dart';

import 'service/firebase_service.dart';
import 'theme/app_theme.dart';
import 'view/auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeFirebase();
    runApp(const AuthApp());
  } catch (_) {
    runApp(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Não foi possível iniciar o Firebase. Confira a configuração do projeto e abra o app novamente.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Auth App',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: const AuthPage(),
  );
}
