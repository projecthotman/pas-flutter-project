import 'package:flutter/material.dart';
import 'package:project/simpanPage.dart';

import 'loginPage_byema.dart';
import 'homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage1(),
    );
  }
}
