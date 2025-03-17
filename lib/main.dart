import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'views/home/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print(await (getApplicationSupportDirectory()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coruja',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 60, 88, 229), brightness: Brightness.dark),
        cardColor: Color.fromARGB(255, 31, 31, 34),
        dividerColor: Color.fromARGB(255, 60, 60, 63),
        dialogTheme: DialogTheme(backgroundColor: const Color.fromARGB(255, 25, 25, 28)),
        cardTheme: CardTheme(color: Color.fromARGB(255, 36, 36, 172)),
        brightness: Brightness.dark,
        inputDecorationTheme: InputDecorationTheme(fillColor: Color.fromARGB(255, 40, 40, 44)),
        textTheme: TextTheme(labelMedium: TextStyle(fontSize: 14), bodyMedium: TextStyle(fontSize: 14)),
      ),
      home: const Home(),
    );
  }
}
