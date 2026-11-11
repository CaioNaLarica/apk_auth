import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
  Future<void> signOut() => _auth.signOut();
}

String authError(Object error) {
  if (error is! FirebaseAuthException) {
    return 'Não foi possível concluir. Tente novamente.';
  }
  return switch (error.code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Email ou senha incorretos.',
    'email-already-in-use' => 'Já existe um usuário com esse email!',
    'weak-password' =>
      'Escolha uma senha mais forte, com pelo menos 6 caracteres.',
    'invalid-email' => 'Digite um email válido.',
    'network-request-failed' =>
      'Não foi possível conectar. Confira sua conexão e tente novamente.',
    'too-many-requests' =>
      'Muitas tentativas. Aguarde um pouco e tente novamente.',
    'user-disabled' => 'Esta conta foi desativada.',
    'operation-not-allowed' =>
      'O login por email e senha precisa ser ativado no Firebase.',
    _ => 'Não foi possível concluir. Tente novamente.',
  };
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Digite seu email.';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    return 'Digite um email válido.';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Digite sua senha.';
  if (value.length < 6) return 'Use pelo menos 6 caracteres.';
  return null;
}
