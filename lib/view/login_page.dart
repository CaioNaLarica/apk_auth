import 'package:flutter/material.dart';

import '../components/app_dialog.dart';
import '../components/app_logo.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/social_button.dart';
import '../service/auth_service.dart';
import '../theme/app_theme.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final auth = AuthService();
  bool busy = false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (busy || !formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => busy = true);
    try {
      await auth.signIn(emailController.text, passwordController.text);
    } catch (e) {
      if (mounted) {
        setState(() => busy = false);
        await showAppAlert(context, authError(e));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> forgotPassword() async {
    final error = validateEmail(emailController.text);
    if (error != null) {
      await showAppAlert(
        context,
        emailController.text.trim().isEmpty
            ? 'Digite seu email primeiro.'
            : error,
      );
      return;
    }
    setState(() => busy = true);
    try {
      await auth.resetPassword(emailController.text);
      if (mounted) {
        setState(() => busy = false);
        await showAppAlert(
          context,
          'Se este email estiver cadastrado, você receberá um link para redefinir sua senha.',
          title: 'Confira seu email',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => busy = false);
        await showAppAlert(context, authError(e));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AuthLayout(
      child: AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(),
              const SizedBox(height: 20),
              const Text(
                'Bem-vindo de volta!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                icon: Icons.email_outlined,
                enabled: !busy,
                validator: validateEmail,
                autofillHints: const [AutofillHints.username],
              ),
              const SizedBox(height: 15),
              MyTextField(
                controller: passwordController,
                hintText: 'Senha',
                icon: Icons.lock_outline,
                enabled: !busy,
                isPassword: true,
                validator: validatePassword,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => signIn(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 4, 17, 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: busy ? null : forgotPassword,
                    child: const Text('Esqueceu a senha?'),
                  ),
                ),
              ),
              MyButton(
                onTap: busy ? null : signIn,
                text: 'Entrar',
                icon: Icons.login,
                loading: busy,
              ),
              const SizedBox(height: 25),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFF2C3850))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'ou continue com',
                        style: TextStyle(color: AppTheme.muted),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFF2C3850))),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    SocialButton(icon: Icons.g_mobiledata, label: 'Google'),
                    SizedBox(width: 12),
                    SocialButton(icon: Icons.apple, label: 'Apple'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: busy
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterPage(),
                        ),
                      ),
                child: const Text('Registre-se agora'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
