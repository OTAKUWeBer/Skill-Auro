import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class QuizService {
  final apiKey = dotenv.env['QUIZ_API_KEY'];
  static const String _cachePrefix = 'quiz_cache_';
  static const int _cacheExpirationHours = 24;

  Future<List<QuizQuestion>> fetchQuiz({
    required QuizMode mode,
    required int limit,
    required Difficulty difficulty,
  }) async {
    final cacheKey = _generateCacheKey(mode, limit, difficulty);

    // Try to get cached data first
    final cached = await _getCachedQuestions(cacheKey);
    if (cached.isNotEmpty) {
      return cached;
    }

    // Fetch from API if not cached
    try {
      final questions = await _fetchFromAPI(mode, limit, difficulty);
      await _cacheQuestions(cacheKey, questions);
      return questions;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QuizQuestion>> _fetchFromAPI(
    QuizMode mode,
    int limit,
    Difficulty difficulty,
  ) async {
    String difficultyParam = difficulty == Difficulty.easy
        ? "Easy"
        : difficulty == Difficulty.normal
            ? "Medium"
            : "Hard";

    final category = mode == QuizMode.linux ? "Linux" : "BASH";
    final tag = mode == QuizMode.linux ? "category=$category" : "tags=$category";

    final url = Uri.parse(
      'https://quizapi.io/api/v1/questions?apiKey=$apiKey&$tag&limit=$limit&difficulty=$difficultyParam',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List;
      return jsonList.map((q) => QuizQuestion.fromJson(q)).toList();
    } else if (response.statusCode == 429) {
      throw Exception("Rate limited. Please try again later.");
    } else {
      throw Exception("Failed to load quiz: ${response.statusCode}");
    }
  }

  Future<List<QuizQuestion>> _getCachedQuestions(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(key);
      if (cached == null) return [];

      final data = jsonDecode(cached) as Map<String, dynamic>;
      final expiryTime = DateTime.parse(data['expiry'] as String);

      if (DateTime.now().isBefore(expiryTime)) {
        final questions = (data['questions'] as List)
            .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
            .toList();
        return questions;
      } else {
        // Cache expired
        await prefs.remove(key);
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> _cacheQuestions(
    String key,
    List<QuizQuestion> questions,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiry =
          DateTime.now().add(const Duration(hours: _cacheExpirationHours));

      final data = {
        'questions': questions.map((q) => q.toJsonWithoutFavorite()).toList(),
        'expiry': expiry.toIso8601String(),
      };

      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      // Silently fail on cache write
    }
  }

  String _generateCacheKey(QuizMode mode, int limit, Difficulty difficulty) {
    return '$_cachePrefix${mode.name}_${limit}_${difficulty.name}';
  }
}

extension QuizQuestionExtension on QuizQuestion {
  Map<String, dynamic> toJsonWithoutFavorite() => {
    'id': id,
    'question': question,
    'answers': answers,
    'correct_answers': correctAnswers,
    'category': category,
    'difficulty': difficulty,
  };
}
