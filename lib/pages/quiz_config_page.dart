import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import 'quiz_page.dart';

class QuizConfigPage extends StatefulWidget {
  final String title;
  final QuizMode mode;

  const QuizConfigPage({super.key, required this.title, required this.mode});

  @override
  State<QuizConfigPage> createState() => _QuizConfigPageState();
}

class _QuizConfigPageState extends State<QuizConfigPage> {
  int questionCount = 10;
  Difficulty difficulty = Difficulty.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Number of Questions",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildCountButton(10)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCountButton(20)),
                      ],
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
                    Text(
                      "Difficulty Level",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildDifficultyButton(
                      Difficulty.easy,
                      "Easy",
                      Icons.sentiment_satisfied,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildDifficultyButton(
                      Difficulty.normal,
                      "Normal",
                      Icons.sentiment_neutral,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildDifficultyButton(
                      Difficulty.hard,
                      "Hard",
                      Icons.sentiment_very_dissatisfied,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPage(
                      title: widget.title,
                      mode: widget.mode,
                      questionCount: questionCount,
                      difficulty: difficulty,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Start Quiz"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountButton(int count) {
    final isSelected = questionCount == count;
    return OutlinedButton(
      onPressed: () => setState(() => questionCount = count),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Text("$count"),
    );
  }

  Widget _buildDifficultyButton(
    Difficulty diff,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = difficulty == diff;
    return OutlinedButton(
      onPressed: () => setState(() => difficulty = diff),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: isSelected ? color.withOpacity(0.1) : null,
        side: BorderSide(
          color: isSelected ? color : Theme.of(context).colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
