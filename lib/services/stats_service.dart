import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';

class StatsService {
  static const String _historyKey = 'quizHistory';
  static const String _favoritesKey = 'favoriteQuestions';
  static const String _streakKey = 'currentStreak';
  static const int _maxHistoryItems = 100;

  Future<void> saveQuizResult({
    required String title,
    required int score,
    required int total,
    required String difficulty,
    required int timeSpent,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    final record = QuizStats(
      title: title,
      score: score,
      total: total,
      difficulty: difficulty,
      date: DateTime.now(),
      timeSpent: timeSpent,
    );

    history.insert(0, jsonEncode(record.toJson()));
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    await prefs.setStringList(_historyKey, history);
    await _updateStreak(score, total);
  }

  Future<List<QuizStats>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    return history
        .map((h) => QuizStats.fromJson(jsonDecode(h)))
        .toList();
  }

  Future<void> toggleFavorite(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    if (favorites.contains(questionId)) {
      favorites.remove(questionId);
    } else {
      favorites.add(questionId);
    }

    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> isFavorite(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.contains(questionId);
  }

  Future<void> _updateStreak(int score, int total) async {
    final prefs = await SharedPreferences.getInstance();
    final passed = (score / total) >= 0.7; // 70% pass threshold

    if (passed) {
      int currentStreak = prefs.getInt(_streakKey) ?? 0;
      await prefs.setInt(_streakKey, currentStreak + 1);
    } else {
      await prefs.setInt(_streakKey, 0);
    }
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<Map<String, dynamic>> getStats() async {
    final history = await getHistory();
    final streak = await getStreak();

    int totalQuestions = 0;
    int totalCorrect = 0;
    int totalTime = 0;

    for (final stat in history) {
      totalQuestions += stat.total;
      totalCorrect += stat.score;
      totalTime += stat.timeSpent;
    }

    return {
      'totalQuizzes': history.length,
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'averageScore':
          totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0,
      'currentStreak': streak,
      'totalTimeMinutes': (totalTime / 60).round(),
    };
  }
}
