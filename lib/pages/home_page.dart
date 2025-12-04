import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/theme_service.dart';
import '../services/api_service.dart';
import 'quiz_config_page.dart';
import 'history_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  final ThemeService themeService;
  final ApiService apiService;

  const HomePage({
    super.key,
    required this.themeService,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skill Auro"),
        actions: [
          IconButton(
            icon: Icon(
              themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeService.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsPage()),
              );
            },
            tooltip: 'Statistics',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
            tooltip: 'Quiz History',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(apiService: apiService),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.quiz,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Choose Your Challenge",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select a quiz category to begin",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildQuizCard(
              context,
              title: "Linux Quiz",
              icon: Icons.computer,
              color: Colors.orange,
              mode: QuizMode.linux,
            ),
            const SizedBox(height: 16),
            _buildQuizCard(
              context,
              title: "Bash Quiz",
              icon: Icons.terminal,
              color: Colors.green,
              mode: QuizMode.bash,
            ),
            const SizedBox(height: 16),
            _buildQuizCard(
              context,
              title: "DevOps Quiz",
              icon: Icons.cloud,
              color: Colors.blue,
              mode: QuizMode.devops,
            ),
            const SizedBox(height: 16),
            _buildQuizCard(
              context,
              title: "HTML Quiz",
              icon: Icons.language,
              color: Colors.red,
              mode: QuizMode.html,
            ),
            const SizedBox(height: 16),
            _buildQuizCard(
              context,
              title: "Code Quiz",
              icon: Icons.code,
              color: Colors.purple,
              mode: QuizMode.code,
            ),
            const SizedBox(height: 16),
            _buildQuizCard(
              context,
              title: "React Quiz",
              icon: Icons.layers,
              color: const Color(0xFF61DAFB),
              mode: QuizMode.react,
            ),
            const SizedBox(height: 16),
            _buildQuizCard(
              context,
              title: "Next.js Quiz",
              icon: Icons.dashboard,
              color: Colors.black,
              mode: QuizMode.nextjs,
            ),
            const SizedBox(height: 16),
            _buildQuizCard(
              context,
              title: "WordPress Quiz",
              icon: Icons.web,
              color: const Color(0xFF21759B),
              mode: QuizMode.wordpress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required QuizMode mode,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizConfigPage(
                title: title,
                mode: mode,
                apiService: apiService,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
