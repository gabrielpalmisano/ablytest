import 'package:ablytest/screen/chat.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AblyTest',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const ChatScreen(),
    );
  }
}
