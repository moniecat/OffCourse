import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding.dart';
import 'screens/sign_in.dart';
import 'screens/home.dart';
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OffCourse', // <--- ADD THIS LINE TO FIX THE TAB NAME
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }

          return const OnboardingScreen();
        },
      ),
      routes: {
        '/login': (_) => const SignInScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}