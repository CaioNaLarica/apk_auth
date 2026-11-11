import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) => Lottie.asset(
    'assets/animations/login.json',
    height: 150,
    repeat: true,
    animate: !MediaQuery.disableAnimationsOf(context),
  );
}
