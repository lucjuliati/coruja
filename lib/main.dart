import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'utils/log_error.dart';
import 'views/home/index.dart';

void main() async {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowMinSize(const Size(800, 600));
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      logError(details.exceptionAsString(), details.stack);
    };

    runApp(const MyApp());
  }, (error, stack) {
    logError(error.toString(), stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coruja',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 30, 63, 232),
          brightness: Brightness.dark,
        ),
        primaryColor: const Color.fromARGB(255, 74, 76, 209),
        cardColor: Color.fromARGB(255, 31, 31, 34),
        dividerColor: Color.fromARGB(255, 60, 60, 63),
        dialogTheme: DialogTheme(backgroundColor: const Color.fromARGB(255, 25, 25, 28)),
        cardTheme: CardTheme(color: Color.fromARGB(255, 36, 36, 172)),
        brightness: Brightness.dark,
        inputDecorationTheme: InputDecorationTheme(fillColor: Color.fromARGB(255, 40, 40, 44)),
        textTheme: TextTheme(
          labelMedium: TextStyle(fontSize: 14),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      home: const Home(),
    );
  }
}
