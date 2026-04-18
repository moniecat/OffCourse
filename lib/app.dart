import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding.dart';
import 'screens/sign_in.dart';
import 'screens/home.dart';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'OffCourse',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
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
        },
      ),
    );
  }
}