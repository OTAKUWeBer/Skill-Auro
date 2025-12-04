import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import 'home_page.dart';
import '../services/theme_service.dart';
import '../services/api_service.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int total;
  final String title;
  final Difficulty difficulty;
  final int timeSpent;
  final List<QuizAttempt> attempts;
  final ApiService apiService;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.title,
    required this.difficulty,
    required this.timeSpent,
    required this.attempts,
    required this.apiService,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool showAnswers = false;

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.score / widget.total) * 100;
    final passed = percentage >= 70;
    final minutes = widget.timeSpent ~/ 60;
    final seconds = widget.timeSpent % 60;

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Results")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: passed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      passed ? Icons.check_circle : Icons.cancel,
                      size: 64,
                      color: passed ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      passed ? "Great Job!" : "Try Again",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: passed ? Colors.green : Colors.red,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Your Score",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${widget.score} / ${widget.total}",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow("Quiz", widget.title),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      "Difficulty",
                      widget.difficulty.toString().split('.').last.toUpperCase(),
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow("Time", "$minutes:${seconds.toString().padLeft(2, '0')}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => setState(() => showAnswers = !showAnswers),
              icon: Icon(showAnswers ? Icons.visibility_off : Icons.visibility),
              label: Text(showAnswers ? "Hide Answers" : "Review Answers"),
            ),
            if (showAnswers) ...[
              const SizedBox(height: 20),
              ...widget.attempts.asMap().entries.map((entry) {
                final index = entry.key;
                final attempt = entry.value;
                final question = attempt.question;
                final userAnswer = attempt.userAnswer;
                final isCorrect = attempt.isCorrect;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.05)
                        : Colors.red.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Q${index + 1}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            question.question,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your answer:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  question.answers[userAnswer] ?? "Not answered",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Correct answer:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                ...question.correctAnswers.entries
                                    .where((e) => e.value == "true")
                                    .map((e) {
                                  final correctKey =
                                      e.key.replaceAll("_correct", "");
                                  return Text(
                                    question.answers[correctKey] ?? "Unknown",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(
                    themeService: ThemeService(),
                    apiService: widget.apiService,
                  ),
                ),
                (route) => false,
              ),
              icon: const Icon(Icons.home),
              label: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ],
    );
  }
}
