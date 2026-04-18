import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFFFB82E),
    scaffoldBackgroundColor: const Color(0xFFFBFBFB),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1A1C1E),
      elevation: 0,
    ),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFFB82E),
      secondary: Color(0xFFFFB82E),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1A1C1E),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1A1C1E)),
      bodyMedium: TextStyle(color: Color(0xFF1A1C1E)),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFFFB82E),
    scaffoldBackgroundColor: const Color(0xFF1A1C1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1C1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: const Color(0xFF2A2D2E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFB82E),
      secondary: Color(0xFFFFB82E),
      surface: Color(0xFF2A2D2E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
}