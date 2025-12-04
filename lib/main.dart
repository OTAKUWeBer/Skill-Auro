import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/theme_service.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  await apiService.initialize();

  runApp(QuizApp(apiService: apiService));
}

class QuizApp extends StatefulWidget {
  final ApiService apiService;

  const QuizApp({super.key, required this.apiService});

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _themeService.addListener(() {
      setState(() {});
    });
    _themeService.loadTheme();
  }

  @override
  void dispose() {
    _themeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skill Auro',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ListenableBuilder(
        listenable: _themeService,
        builder: (context, _) => HomePage(
          themeService: _themeService,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        brightness: brightness,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
