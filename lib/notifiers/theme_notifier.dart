import 'dart:io';

import 'package:first_priority_app/Constants.dart';
import 'package:first_priority_app/storage_manager.dart';
import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  static final ThemeData darkTheme = buildTheme(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      // primary: Color.fromARGB(255, 0, 33, 91),
      // primaryVariant: Colors.pink,
      // secondary: Color.fromARGB(255, 178, 8, 56),
      // secondaryVariant: Color.fromARGB(255, 157, 7, 49),
      primary: Color.fromARGB(255, 178, 8, 56),
      primaryVariant: Color.fromARGB(255, 157, 7, 49),
      secondary: Color.fromARGB(255, 0, 33, 91),
      secondaryVariant: Color.fromARGB(255, 0, 22, 61),
      surface: Color.fromARGB(255, 40, 40, 40),
      background: Color.fromARGB(255, 25, 25, 25),
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),
    surfaceBright: Colors.white12,
    bodyText1: TextStyle(color: Colors.white, fontSize: 16),
    headline1: getCustomTextProperties(Colors.white, 30, fontSchylerRegular, 1),
    defaultText: TextStyle(color: Colors.white, fontSize: 16),
    subtitle2:
        getCustomTextProperties(Colors.white54, 16, fontSchylerRegular, 1),
    headline3: getCustomTextProperties(Colors.white, 16, fontSchylerRegular, 1),
    headline4:
        getCustomTextProperties(Colors.white54, 14, fontSchylerRegular, 0),
    bodyText2: TextStyle(color: Colors.white70),
    navBackgroundColor: Color.fromARGB(255, 27, 27, 27),
    navUnselectedColor: Colors.white54,
    dividerColor: Color.fromARGB(255, 61, 61, 61),
  );

  static final ThemeData lightTheme = buildTheme(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color.fromARGB(255, 0, 33, 91),
      primaryVariant: Color.fromARGB(255, 0, 22, 61),
      secondary: Color.fromARGB(255, 178, 8, 56),
      secondaryVariant: Color.fromARGB(255, 157, 7, 49),
      surface: Color.fromARGB(255, 242, 242, 247),
      background: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
    ),
    surfaceBright: Colors.black12,
    headline1: getCustomTextProperties(Colors.black, 30, fontSchylerRegular, 1),
    defaultText: TextStyle(
      color: Colors.black,
      fontSize: 16,
    ),
    subtitle2:
        getCustomTextProperties(Colors.black54, 16, fontSchylerRegular, 1),
    headline4:
        getCustomTextProperties(colorLightDark, 14, fontSchylerRegular, 0),
    headline3: getCustomTextProperties(Colors.black, 16, fontSchylerRegular, 1),
    navBackgroundColor: Colors.white,
    navUnselectedColor: Colors.black12,
    dividerColor: colorLightGray,
  );

  static final _themes = {
    'light': {
      'mode': ThemeMode.light,
      'data': lightTheme,
    },
    'dark': {
      'mode': ThemeMode.dark,
      'data': darkTheme,
    },
  };

  ThemeData _themeData;
  String _themeKey;
  ThemeMode _themeMode;

  ThemeData get current => _themeData;
  String get key => _themeKey;
  ThemeMode get mode => _themeMode;

  ThemeNotifier() {
    StorageManager.read("theme").then((theme) {
      _applyTheme(theme);
    });
  }

  void setTheme(String theme) {
    _applyTheme(theme);
    StorageManager.save("theme", theme);
  }

  void _applyTheme(String theme) {
    theme ??= _themes.keys.first;

    _themeKey = theme;
    _themeData = _themes[theme]["data"];
    _themeMode = _themes[_themeKey]["mode"];
    notifyListeners();
  }
}

ThemeData buildTheme({
  Brightness brightness,
  ColorScheme colorScheme,
  Color surfaceBright,
  TextStyle headline1,
  TextStyle headline3,
  TextStyle headline4,
  TextStyle defaultText,
  TextStyle subtitle2,
  TextStyle bodyText1,
  TextStyle bodyText2,
  Color navBackgroundColor,
  Color navUnselectedColor,
  Color dividerColor,
}) {
  return ThemeData(
    brightness: brightness,
    fontFamily: 'Schyler',
    backgroundColor: colorScheme.background,
    scaffoldBackgroundColor: colorScheme.background,
    secondaryHeaderColor: surfaceBright,
    colorScheme: colorScheme,
    textTheme: TextTheme(
      headline1: headline1,
      headline3: headline3,
      headline4: headline4,
      bodyText2: bodyText2,
      subtitle1: defaultText,
      subtitle2: subtitle2,
      bodyText1: bodyText1,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: colorScheme.surface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: colorScheme.onBackground,
      ),
      contentPadding: EdgeInsets.all(4),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.secondary),
      ),
    ),
    textSelectionTheme:
        TextSelectionThemeData(cursorColor: colorScheme.secondaryVariant),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    canvasColor: colorScheme.surface,
    dividerColor: dividerColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 2,
        primary: colorScheme.primary,
        minimumSize: Size(double.infinity, 40),
        textStyle: TextStyle(
          fontFamily: fontSchylerRegular,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onPrimary,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 2,
      backgroundColor: colorScheme.background,
      unselectedItemColor: navUnselectedColor,
      selectedItemColor: colorScheme.primary,
    ),
    appBarTheme: AppBarTheme(
      foregroundColor: colorScheme.onSurface,
      color: colorScheme.surface,
      centerTitle: true,
      toolbarHeight: Platform.isIOS ? 48 : null,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(colorScheme.onBackground),
        textStyle: MaterialStateProperty.all(
          TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(colorScheme.primary),
    ),
  );
}
