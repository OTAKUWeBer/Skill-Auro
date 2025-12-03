import 'package:flutter/material.dart';
import '../services/stats_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final statsService = StatsService();
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = statsService.getStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistics")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error loading statistics"));
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatCard(
                  context,
                  title: "Total Quizzes",
                  value: "${stats['totalQuizzes']}",
                  icon: Icons.quiz,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  title: "Average Score",
                  value:
                      "${(stats['averageScore'] as double).toStringAsFixed(1)}%",
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  title: "Current Streak",
                  value: "${stats['currentStreak']}",
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  title: "Total Time",
                  value: "${stats['totalTimeMinutes']} min",
                  icon: Icons.timer,
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  title: "Questions Answered",
                  value: "${stats['totalQuestions']}",
                  icon: Icons.check_circle,
                  color: Colors.teal,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
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
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
