import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'theme.dart';

class CalorieApp extends StatelessWidget {
  const CalorieApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Kalori Takip',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F7F5),
      colorScheme: ColorScheme.fromSeed(seedColor: green),
    ),
    home: const Home(),
  );
}
