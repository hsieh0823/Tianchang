import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '天城 AI 助理',
      home: Scaffold(
        appBar: AppBar(title: const Text('天城 AI 助理')),
        body: const Center(child: Text('你好，我是天城')),
      ),
    );
  }
}
