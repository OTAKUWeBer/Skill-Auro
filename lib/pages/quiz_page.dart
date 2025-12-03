import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
import '../services/stats_service.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  final String title;
  final QuizMode mode;
  final int questionCount;
  final Difficulty difficulty;

  const QuizPage({
    super.key,
    required this.title,
    required this.mode,
    required this.questionCount,
    required this.difficulty,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final quizService = QuizService();
  final statsService = StatsService();
  List<QuizQuestion> questions = [];
  List<QuizAttempt> attempts = [];
  bool loading = true;
  int index = 0;
  int score = 0;
  String? selectedAnswer;
  bool showFeedback = false;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _loadQuiz();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      final data = await quizService.fetchQuiz(
        mode: widget.mode,
        limit: widget.questionCount,
        difficulty: widget.difficulty,
      );

      setState(() {
        questions = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _answer(String key) {
    final isCorrect =
        questions[index].correctAnswers["${key}_correct"] == "true";
    
    attempts.add(
      QuizAttempt(
        question: questions[index],
        userAnswer: key,
        isCorrect: isCorrect,
      ),
    );

    setState(() {
      selectedAnswer = key;
      showFeedback = true;
    });

    if (isCorrect) score++;

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        if (index < questions.length - 1) {
          setState(() {
            index++;
            selectedAnswer = null;
            showFeedback = false;
          });
        } else {
          _finishQuiz();
        }
      }
    });
  }

  Future<void> _finishQuiz() async {
    _stopwatch.stop();
    
    await statsService.saveQuizResult(
      title: widget.title,
      score: score,
      total: questions.length,
      difficulty: widget.difficulty.toString().split('.').last,
      timeSpent: _stopwatch.elapsed.inSeconds,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: score,
            total: questions.length,
            title: widget.title,
            difficulty: widget.difficulty,
            timeSpent: _stopwatch.elapsed.inSeconds,
            attempts: attempts,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              const Text("No questions available"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    final q = questions[index];
    final progress = (index + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Q${index + 1}/${questions.length}"),
                    Text("Score: $score"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  q.question,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...q.answers.entries.where((e) => e.value != null).map((e) {
              final isCorrect = q.correctAnswers["${e.key}_correct"] == "true";
              final isSelected = selectedAnswer == e.key;

              Color? backgroundColor;
              Color? borderColor;

              if (showFeedback && isSelected) {
                backgroundColor = isCorrect
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2);
                borderColor = isCorrect ? Colors.green : Colors.red;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton(
                  onPressed: showFeedback ? null : () => _answer(e.key),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: backgroundColor,
                    side: BorderSide(
                      color: borderColor ??
                          Theme.of(context).colorScheme.outline,
                      width: borderColor != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (showFeedback && isSelected)
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      if (showFeedback && isSelected)
                        const SizedBox(width: 12),
                      Expanded(child: Text(e.value ?? "")),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
