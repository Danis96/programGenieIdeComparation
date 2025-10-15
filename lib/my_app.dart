import 'package:flutter/material.dart';
import 'package:programgenieplugins/feedback/feedback_provider.dart';
import 'package:programgenieplugins/view/comparison_view.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FeedbackProvider())],
      child: MaterialApp(
        title: 'IDE Plugin Comparison ProgramGenie',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const ComparisonPage(),
      ),
    );
  }
}
