import 'package:flutter/material.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Poppins',
  primaryColor: const Color(0xFF5C6CFF),
  secondaryHeaderColor: const Color(0xFF9FB2FF),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0F142D),
  cardColor: const Color(0xFF171D3B),
  hintColor: const Color(0xFFA7B0C0),
  disabledColor: const Color(0xFF6C7484),
  shadowColor: Colors.black.withOpacity(0.35),
  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
  popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF171D3B), surfaceTintColor: Color(0xFF171D3B)),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF5C6CFF),
    secondary: Color(0xFF9FB2FF),
    error: Colors.redAccent,
  ),
  // cardTheme: const CardTheme(
  //   elevation: 6,
  //   color: Color(0xFF171D3B),
  //   surfaceTintColor: Color(0xFF171D3B),
  //   shadowColor: Color(0x66000000),
  //   shape: RoundedRectangleBorder(
  //     borderRadius: BorderRadius.all(Radius.circular(16)),
  //   ),
  // ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F142D),
    foregroundColor: Color(0xFFE8ECFF),
    elevation: 0,
    surfaceTintColor: Color(0xFF0F142D),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF171D3B),
    hintStyle: TextStyle(color: Color(0xFFA7B0C0)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFF2C3668), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFF5C6CFF), width: 1.5),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5C6CFF),
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF9FB2FF),
      side: const BorderSide(color: Color(0xFF5C6CFF), width: 1.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF9FB2FF),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF0F142D),
    selectedItemColor: Color(0xFF5C6CFF),
    unselectedItemColor: Color(0xFFA7B0C0),
    elevation: 8,
  ),
  textTheme: const TextTheme(
    labelLarge: TextStyle(color: Color(0xFFE8ECFF)),
    displayLarge: TextStyle(
        fontWeight: FontWeight.w300, fontSize: Dimensions.fontSizeDefault),
    displayMedium: TextStyle(
        fontWeight: FontWeight.w400, fontSize: Dimensions.fontSizeDefault),
    displaySmall: TextStyle(
        fontWeight: FontWeight.w500, fontSize: Dimensions.fontSizeDefault),
    headlineMedium: TextStyle(
        fontWeight: FontWeight.w600, fontSize: Dimensions.fontSizeDefault),
    headlineSmall: TextStyle(
        fontWeight: FontWeight.w700, fontSize: Dimensions.fontSizeDefault),
    titleLarge: TextStyle(
        fontWeight: FontWeight.w800, fontSize: Dimensions.fontSizeDefault),
    bodySmall: TextStyle(
        fontWeight: FontWeight.w900, fontSize: Dimensions.fontSizeDefault),
    titleMedium: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(fontSize: 12.0),
    bodyLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
  ),
  tabBarTheme: const TabBarThemeData(indicatorColor: Color(0xFF5C6CFF)),
);
