import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends ChangeNotifier {
  static const String _apiKeyPrefKey = 'quiz_api_key';
  static const String _defaultApiKey = 'qM1u3KxfIg9f8jJGNQX6IRUQdrPpwUPcJtTOfXq0';

  late SharedPreferences _prefs;
  late String _apiKey;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs.getString(_apiKeyPrefKey) ?? _defaultApiKey;
  }

  String get apiKey => _apiKey;

  Future<void> setApiKey(String key) async {
    if (key.isEmpty) {
      throw Exception('API key cannot be empty');
    }
    _apiKey = key;
    await _prefs.setString(_apiKeyPrefKey, key);
    notifyListeners();
  }

  Future<void> resetToDefault() async {
    _apiKey = _defaultApiKey;
    await _prefs.remove(_apiKeyPrefKey);
    notifyListeners();
  }
}
