import 'package:flutter/material.dart';
import 'package:programgenieplugins/app/feedback/feedback_provider.dart';
import 'package:programgenieplugins/app/theme/app_theme.dart';
import 'package:programgenieplugins/app/view/comparison_view.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleThemeMode() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FeedbackProvider())],
      child: MaterialApp(
        title: 'IDE Plugin Comparison ProgramGenie',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _themeMode,
        home: ComparisonPage(
          themeMode: _themeMode,
          onToggleThemeMode: _toggleThemeMode,
        ),
      ),
    );
  }
}
