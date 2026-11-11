import 'package:apk_auth/main.dart';
import 'package:apk_auth/service/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'cadastro, notas CRUD, logout, senha incorreta, recuperação e login',
    (tester) async {
      tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      tester.testTextInput.register();
      addTearDown(tester.testTextInput.unregister);
      await initializeFirebase();
      await FirebaseAuth.instance.signOut();
      await tester.pumpWidget(const AuthApp());
      await tester.pumpAndSettle();
      final email = 'teste${DateTime.now().millisecondsSinceEpoch}@exemplo.com';
      const password = 'Teste123!';
      Finder field(String hint) => find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == hint,
      );
      Future<void> enter(String hint, String value) async {
        await tester.ensureVisible(field(hint));
        await tester.pumpAndSettle();
        await tester.enterText(field(hint), value);
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(field(hint)).controller!.text == value,
          isTrue,
          reason: 'O campo $hint deve receber o texto digitado.',
        );
      }

      Future<void> tapText(String text) async {
        final finder = find.text(text);
        if (finder.evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            finder,
            200,
            scrollable: find.byType(Scrollable).first,
          );
        }
        await tester.ensureVisible(finder.last);
        await tester.pumpAndSettle();
        await tester.tap(finder.last);
        await tester.pumpAndSettle();
      }

      Future<void> waitText(String text) async {
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 250));
          if (find.text(text).evaluate().isNotEmpty) {
            await tester.pumpAndSettle();
            return;
          }
        }
        debugPrint(
          'UI: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList()}',
        );
        debugPrint('Sessão: ${FirebaseAuth.instance.currentUser?.email}');
        fail('Não apareceu: $text');
      }

      await tapText('Entrar');
      expect(find.text('Digite seu email.'), findsOneWidget);
      await tapText('Registre-se agora');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      await tapText('Registre-se agora');
      await enter('Email', email);
      await enter('Senha', password);
      await enter('Confirmar senha', 'Diferente123');
      await tapText('Registrar');
      expect(find.text('Senhas não conferem!'), findsOneWidget);
      await enter('Confirmar senha', password);
      expect(
        tester.widget<TextField>(field('Senha')).controller!.text == password,
        isTrue,
        reason: 'Senha original preservada.',
      );
      await tapText('Registrar');
      await waitText('Meu perfil');
      expect(find.text('Olá, $email'), findsOneWidget);
      await tapText('Minhas notas');
      await waitText('Sem notas por aqui');
      await tester.tap(find.byTooltip('Adicionar nota'));
      await tester.pumpAndSettle();
      await tapText('Adicionar');
      expect(find.text('Escreva algo antes de salvar.'), findsOneWidget);
      await enter('Escreva sua nota...', 'Minha primeira nota');
      await tapText('Adicionar');
      await waitText('Minha primeira nota');
      await tester.tap(find.byTooltip('Editar nota'));
      await tester.pumpAndSettle();
      await enter('Escreva sua nota...', 'Nota atualizada');
      await tapText('Salvar');
      await waitText('Nota atualizada');
      await tester.tap(find.byTooltip('Excluir nota'));
      await tester.pumpAndSettle();
      await tapText('Cancelar');
      expect(find.text('Nota atualizada'), findsOneWidget);
      await tester.tap(find.byTooltip('Excluir nota'));
      await tester.pumpAndSettle();
      await tapText('Excluir');
      await waitText('Sem notas por aqui');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Sair'));
      await waitText('Bem-vindo de volta!');
      await enter('Email', email);
      await enter('Senha', 'SenhaErrada123');
      await tapText('Entrar');
      await waitText('Email ou senha incorretos.');
      await tapText('OK');
      await tapText('Esqueceu a senha?');
      await waitText('Confira seu email');
      await tapText('OK');
      await enter('Senha', password);
      await tapText('Entrar');
      await waitText('Meu perfil');
      expect(find.text('Olá, $email'), findsOneWidget);
      await tester.tap(find.byTooltip('Sair'));
      await waitText('Bem-vindo de volta!');
    },
  );
}
