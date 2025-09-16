import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.pink,
  textTheme: GoogleFonts.interTextTheme(),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFF2D7EB),
    selectedItemColor: Color(0xFFDE4949),
    unselectedItemColor: Color(0xFFF49BAB),
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: Colors.deepPurple),
  ),
);
