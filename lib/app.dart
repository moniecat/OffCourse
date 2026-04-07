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
      debugShowCheckedModeBanner: false,
      // Use a StreamBuilder on authStateChanges so the app automatically
      // routes to Home when already signed in, or to Sign-In when signed out.
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          // While Firebase resolves the auth state, show a loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // User is signed in → go straight to Home
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }

          // Not signed in → show Onboarding
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
