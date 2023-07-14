import 'package:demoday_6/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.redAccent,
        textTheme: TextTheme(bodyMedium: GoogleFonts.openSans(fontSize: 18)),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          foregroundColor: Colors.primaries[1],
          titleTextStyle: GoogleFonts.nunitoSans(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.primaries[1],
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
