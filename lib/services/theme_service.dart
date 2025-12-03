import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  bool isDarkMode = false;
  late SharedPreferences _prefs;

  Future<void> loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    isDarkMode = _prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    await _prefs.setBool('darkMode', isDarkMode);
    notifyListeners();
  }
}
