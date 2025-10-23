import 'package:flutter/material.dart';
import 'package:smeta_maker/data/app_constants.dart';

abstract class AppColors {
  static const Color background = Color(0xFF1F1F1F),
      text = Colors.white,
      complex = Color(0xFF4B6134),
      sht = Color(0xFF615A34),
      meters = Color(0xFF423461),
      quadMeters = Color(0xFF613435),
      delete = Color(0xFFAA1E1E),
      mainButton = Color(0xFF6B6B6B),
      secondButton = Color(0xFF505050),
      totalShow = Color(0xFF344261);
}

abstract class AppTheme {
  static final ButtonStyle dropdownStyle = ButtonStyle(
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 20)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(15)),
    ),
    side: WidgetStatePropertyAll(BorderSide(color: Colors.white, width: .5)),
    iconColor: WidgetStateColor.resolveWith((states) => Colors.white),
    textStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        color: AppColors.text,
        fontFamily: 'PlusJakartaSans',
        fontSize: 20,
      ),
    ),
  );
  static final TextStyle _button = TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 20,
        color: AppColors.text,
      ),
      _body = TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: AppColors.text,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static ThemeData dark = ThemeData(
    fontFamily: 'PlusJakartaSans',
    brightness: Brightness.dark,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
    ),
    scaffoldBackgroundColor: AppColors.background,
    dialogTheme: DialogThemeData(backgroundColor: AppColors.background),
    appBarTheme: AppBarTheme(backgroundColor: AppColors.background),
    textTheme: TextTheme(
      bodyMedium: _body,
      bodyLarge: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontWeight: FontWeight.w500,
        color: AppColors.text,
        fontSize: 18,
        height: 1.1,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColors.secondButton,
      cursorColor: AppColors.mainButton,
      selectionHandleColor: AppColors.mainButton,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: TextStyle(color: AppColors.secondButton),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateColor.resolveWith((states) => Colors.white),
      trackOutlineColor: WidgetStateColor.resolveWith(
        (states) => Colors.transparent,
      ),
      trackColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.totalShow
            : AppColors.mainButton,
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: TextStyle(fontFamily: 'PlusJakartaSans'),
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      menuStyle: MenuStyle(alignment: Alignment.center),
    ),

    listTileTheme: ListTileThemeData(titleTextStyle: _body),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: AppColors.mainButton,
        textStyle: _button,
        foregroundColor: AppColors.text,
        padding: EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.all),
      ),
    ),
  );
}
