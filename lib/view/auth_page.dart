import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final Stream<User?> _authChanges = FirebaseAuth.instance
      .authStateChanges();
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: _authChanges,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return const Scaffold(
          body: Center(child: Text('Não foi possível carregar sua sessão.')),
        );
      }
      return snapshot.hasData
          ? HomePage(user: snapshot.data!, key: ValueKey(snapshot.data!.uid))
          : const LoginPage();
    },
  );
}
