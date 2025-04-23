import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Al-Quran',
      theme: ThemeData(
        primarySwatch: Colors.green, // Warna utama hijau
        scaffoldBackgroundColor: Colors.green[50], // Warna latar belakang
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green, // Warna AppBar
          foregroundColor: Colors.white, // Warna teks di AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Warna tombol
            foregroundColor: Colors.white, // Warna teks tombol
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}