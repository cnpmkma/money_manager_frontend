import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.pink,
  textTheme: GoogleFonts.interTextTheme(),
  scaffoldBackgroundColor: Colors.grey[100],
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFF49BAB),
    selectedItemColor: Colors.pinkAccent,
    unselectedItemColor: Color(0xFFFFE1E0),
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  ),
);