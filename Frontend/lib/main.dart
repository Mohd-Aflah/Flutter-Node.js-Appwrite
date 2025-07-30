import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/intern_list_screen.dart';

void main() {
  runApp(const InternManagementApp());
}

class InternManagementApp extends StatelessWidget {
  const InternManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Intern Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      home: const InternListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
