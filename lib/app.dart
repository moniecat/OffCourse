import 'package:flutter/material.dart';
import 'screens/onboarding.dart';
import 'screens/sign_in.dart';
import 'screens/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
      routes: {
        '/login': (_) => const SignInScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
