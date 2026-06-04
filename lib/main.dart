import 'package:flutter/material.dart';
import 'package:reportaya/pages/log_in/log_in_page.dart';
import 'package:reportaya/pages/start/start_page.dart';
import './configs/theme.dart';

import 'package:reportaya/pages/register/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final TextTheme baseTextTheme = Typography.material2021().englishLike;
    final ReportaYaTheme reportaYaTheme = ReportaYaTheme(baseTextTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReportaYA',
      theme: reportaYaTheme.light(),
      initialRoute: '/log-in',
      routes: {
        '/log-in': (context) => LogInPage(),
        '/start': (context) => const StartPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
