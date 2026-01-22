import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shot Trace App',
      theme: ThemeData(
        // アプリのテーマを定義
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 23, 172, 80)),
      ),
      home: const HomeScreen(title: 'Shot Trace App'),
    );
  }
}

