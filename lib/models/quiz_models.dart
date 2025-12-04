enum QuizMode { linux, bash, devops, html, code, react, nextjs, wordpress, computerscience }
enum Difficulty { easy, medium, hard }

class QuizQuestion {
  final String id;
  final String question;
  final Map<String, String?> answers;
  final Map<String, String> correctAnswers;
  final String category;
  final String difficulty;
  bool isFavorite;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswers,
    required this.category,
    required this.difficulty,
    this.isFavorite = false,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'].toString(),
      question: json['question'],
      answers: Map<String, String?>.from(json['answers'] ?? {}),
      correctAnswers: Map<String, String>.from(json['correct_answers'] ?? {}),
      category: json['category'] ?? 'General',
      difficulty: json['difficulty'] ?? 'Medium',
    );
  }
}

class QuizStats {
  final String title;
  final int score;
  final int total;
  final String difficulty;
  final DateTime date;
  final int timeSpent; // in seconds

  QuizStats({
    required this.title,
    required this.score,
    required this.total,
    required this.difficulty,
    required this.date,
    required this.timeSpent,
  });

  double get percentage => (score / total) * 100;

  factory QuizStats.fromJson(Map<String, dynamic> json) {
    return QuizStats(
      title: json['title'],
      score: json['score'],
      total: json['total'],
      difficulty: json['difficulty'],
      date: DateTime.parse(json['date']),
      timeSpent: json['timeSpent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'score': score,
    'total': total,
    'difficulty': difficulty,
    'date': date.toIso8601String(),
    'timeSpent': timeSpent,
  };
}

class QuizAttempt {
  final QuizQuestion question;
  final String? userAnswer;
  final bool isCorrect;

  QuizAttempt({
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
  });
}
