import 'package:flutter/material.dart';

import '../components/app_dialog.dart';
import '../components/app_logo.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../service/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool busy = false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (busy || !formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => busy = true);
    try {
      await AuthService().register(
        emailController.text,
        passwordController.text,
      );
      if (mounted) Navigator.pop(context);
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
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: busy ? () {} : () => Navigator.pop(context),
        ),
        title: const Text('Crie sua conta'),
      ),
      body: AuthLayout(
        child: AutofillGroup(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(),
                const SizedBox(height: 24),
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
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: confirmController,
                  hintText: 'Confirmar senha',
                  icon: Icons.lock_outline,
                  enabled: !busy,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => register(),
                  validator: (value) => value != passwordController.text
                      ? 'Senhas não conferem!'
                      : validatePassword(value),
                ),
                const SizedBox(height: 25),
                MyButton(
                  onTap: busy ? null : register,
                  text: 'Registrar',
                  icon: Icons.person_add_outlined,
                  loading: busy,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
