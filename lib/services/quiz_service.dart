import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';
import 'api_service.dart';
import 'dart:async';

class QuizException implements Exception {
  final String message;
  QuizException(this.message);

  @override
  String toString() => message;
}

class QuizService {
  final _random = Random();
  final ApiService apiService;

  static const String _cachePrefix = 'quiz_cache_';
  static const int _cacheExpirationHours = 24;

  QuizService({required this.apiService});

  String _getApiKey() {
    return apiService.apiKey;
  }

  Future<List<QuizQuestion>> fetchQuiz({
    required QuizMode mode,
    required int limit,
    required Difficulty difficulty,
  }) async {
    final cacheKey = _generateCacheKey(mode, limit, difficulty);

    // Try to get cached data first
    final cached = await _getCachedQuestions(cacheKey);
    if (cached.isNotEmpty) {
      return _shuffleQuestions(cached);
    }

    // Fetch from API if not cached
    try {
      final questions = await _fetchFromAPI(mode, limit, difficulty);
      await _cacheQuestions(cacheKey, questions);
      return _shuffleQuestions(questions);
    } catch (e) {
      rethrow;
    }
  }

  List<QuizQuestion> _shuffleQuestions(List<QuizQuestion> questions) {
    // Shuffle the list of questions
    final shuffledQuestions = List<QuizQuestion>.from(questions)..shuffle(_random);
    
    // Shuffle answer options for each question
    return shuffledQuestions.map((q) => _shuffleAnswers(q)).toList();
  }

  QuizQuestion _shuffleAnswers(QuizQuestion question) {
    // Get all answer entries
    final answerEntries = question.answers.entries.toList();
    
    // Create a list of non-null answers with their keys
    final validAnswers = answerEntries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .toList();
    
    if (validAnswers.isEmpty) return question;
    
    // Shuffle the valid answers
    validAnswers.shuffle(_random);
    
    // Create new answers map with shuffled order
    final newAnswers = <String, String?>{};
    final keys = ['answer_a', 'answer_b', 'answer_c', 'answer_d', 'answer_e', 'answer_f'];
    
    for (int i = 0; i < validAnswers.length && i < keys.length; i++) {
      newAnswers[keys[i]] = validAnswers[i].value;
    }
    
    // Fill remaining slots with null
    for (int i = validAnswers.length; i < keys.length; i++) {
      newAnswers[keys[i]] = null;
    }
    
    // Create mapping from old keys to new keys
    final keyMapping = <String, String>{};
    for (int i = 0; i < validAnswers.length; i++) {
      keyMapping[validAnswers[i].key] = keys[i];
    }
    
    // Update correct answers with new keys
    final newCorrectAnswers = <String, String>{};
    question.correctAnswers.forEach((key, value) {
      final baseKey = key.replaceAll('_correct', '');
      final newKey = keyMapping[baseKey];
      if (newKey != null) {
        newCorrectAnswers['${newKey}_correct'] = value;
      } else {
        newCorrectAnswers[key] = value;
      }
    });
    
    return QuizQuestion(
      id: question.id,
      question: question.question,
      answers: newAnswers,
      correctAnswers: newCorrectAnswers,
      category: question.category,
      difficulty: question.difficulty,
    );
  }

  Future<List<QuizQuestion>> _fetchFromAPI(
    QuizMode mode,
    int limit,
    Difficulty difficulty,
  ) async {
    if (mode == QuizMode.computerscience) {
      return _fetchFromOpenTDB(limit, difficulty);
    }

    String difficultyParam = difficulty == Difficulty.easy
        ? "Easy"
        : difficulty == Difficulty.medium
            ? "Medium"
            : "Hard";

    final category = mode == QuizMode.linux
        ? "Linux"
        : mode == QuizMode.bash
            ? "Bash"
        : mode == QuizMode.devops
            ? "DevOps"
        : mode == QuizMode.html
            ? "HTML"
        : mode == QuizMode.code
            ? "Code"
        : mode == QuizMode.react
            ? "React"
        : mode == QuizMode.nextjs
            ? "Next.js"
        : "WordPress";
    
    final tag = "category=$category";

    final apiKey = _getApiKey();
    final baseUrl = 'https://quizapi.io/api/v1/questions';
    final queryParams = 'apiKey=$apiKey&$tag&limit=$limit&difficulty=$difficultyParam';
    final url = Uri.parse('$baseUrl?$queryParams');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List;
        return jsonList.map((q) => QuizQuestion.fromJson(q)).toList();
      } else if (response.statusCode == 429) {
        throw QuizException("Rate limited. Please try again later.");
      } else {
        throw QuizException("Failed to load quiz: HTTP ${response.statusCode}");
      }
    } catch (e) {
      if (e is QuizException) {
        rethrow;
      } else if (e is SocketException) {
        throw QuizException("Network error: Unable to connect. Please check your internet connection.");
      } else if (e is TimeoutException) {
        throw QuizException("Request timed out. Please try again.");
      } else {
        throw QuizException("Unable to load quiz. Please try again later.");
      }
    }
  }

  Future<List<QuizQuestion>> _fetchFromOpenTDB(
    int limit,
    Difficulty difficulty,
  ) async {
    String difficultyParam = difficulty == Difficulty.easy
        ? "easy"
        : difficulty == Difficulty.medium
            ? "medium"
            : "hard";

    final url = Uri.parse(
      'https://opentdb.com/api.php?amount=$limit&category=18&difficulty=$difficultyParam'
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final results = jsonData['results'] as List;
        
        return results.map((q) => _parseOpenTDBQuestion(q)).toList();
      } else {
        throw QuizException("Failed to load quiz: HTTP ${response.statusCode}");
      }
    } catch (e) {
      if (e is QuizException) {
        rethrow;
      } else if (e is SocketException) {
        throw QuizException("Network error: Unable to connect. Please check your internet connection.");
      } else if (e is TimeoutException) {
        throw QuizException("Request timed out. Please try again.");
      } else {
        throw QuizException("Unable to load quiz. Please try again later.");
      }
    }
  }

  QuizQuestion _parseOpenTDBQuestion(Map<String, dynamic> q) {
    final question = _htmlDecode(q['question'] as String);
    final correctAnswer = _htmlDecode(q['correct_answer'] as String);
    final incorrectAnswers = (q['incorrect_answers'] as List)
        .map((a) => _htmlDecode(a as String))
        .toList();
    
    // Combine all answers
    final allAnswers = [correctAnswer, ...incorrectAnswers]..shuffle(_random);
    
    // Map answers to the standard format (answer_a, answer_b, etc.)
    final answersMap = <String, String?>{};
    final correctAnswersMap = <String, String>{};
    
    for (int i = 0; i < allAnswers.length && i < 6; i++) {
      final key = ['answer_a', 'answer_b', 'answer_c', 'answer_d', 'answer_e', 'answer_f'][i];
      answersMap[key] = allAnswers[i];
      
      if (allAnswers[i] == correctAnswer) {
        correctAnswersMap['${key}_correct'] = 'true';
      } else {
        correctAnswersMap['${key}_correct'] = 'false';
      }
    }
    
    // Fill remaining slots with null
    for (int i = allAnswers.length; i < 6; i++) {
      final key = ['answer_a', 'answer_b', 'answer_c', 'answer_d', 'answer_e', 'answer_f'][i];
      answersMap[key] = null;
    }
    
    return QuizQuestion(
      id: question.hashCode.toString(),
      question: question,
      answers: answersMap,
      correctAnswers: correctAnswersMap,
      category: 'Computer Science',
      difficulty: q['difficulty'] as String,
    );
  }

  String _htmlDecode(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');
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
