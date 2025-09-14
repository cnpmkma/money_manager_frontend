import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.green,
  textTheme: GoogleFonts.interTextTheme(),
  scaffoldBackgroundColor: Colors.grey[100],
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.green,
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
  ),
);