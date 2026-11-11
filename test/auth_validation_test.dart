import 'package:apk_auth/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valida email e aceita espaços externos', () {
    expect(validateEmail(''), isNotNull);
    expect(validateEmail('sem-arroba'), isNotNull);
    expect(validateEmail('a@b'), isNotNull);
    expect(validateEmail(' pessoa@exemplo.com '), isNull);
  });
  test('exige senha com no mínimo seis caracteres', () {
    expect(validatePassword(''), isNotNull);
    expect(validatePassword('12345'), isNotNull);
    expect(validatePassword('123456'), isNull);
  });
  test('traduz falhas de autenticação para português', () {
    expect(
      authError(FirebaseAuthException(code: 'invalid-credential')),
      'Email ou senha incorretos.',
    );
    expect(
      authError(FirebaseAuthException(code: 'email-already-in-use')),
      contains('Já existe'),
    );
    expect(
      authError(FirebaseAuthException(code: 'network-request-failed')),
      contains('conexão'),
    );
  });
}
