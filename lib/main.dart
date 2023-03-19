import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe/screens/game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}
