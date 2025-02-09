import 'package:flutter/material.dart';
import 'package:gpa_cal_app/Pages/homePage.dart';

void main() {
  runApp(const MainApp());

  // runApp(const MaterialApp(
  //   debugShowCheckedModeBanner: false,
  //   theme: ThemeData(
  //     scaffoldBackgroundColor: const Color(0xFF493D9E),
  //   ),
  //   // title: 'BookHUB',
  //   home: HomePage(),
  // ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(178, 165, 167, 255),
        fontFamily: 'Ubuntu',
      ),
      home: const HomePage(),
    );
  }
}
