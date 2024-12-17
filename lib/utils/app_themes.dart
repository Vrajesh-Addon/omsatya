import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';

class AppThemes {
  static ThemeMode themeMode = ThemeMode.dark;

  get light {
    return ThemeData(
      colorScheme: AppColors.colorSchemeLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      useMaterial3: false,
      scaffoldBackgroundColor: Colors.grey.shade100,
      inputDecorationTheme: _inputDecorationTheme,
      dropdownMenuTheme: _dropDownMenuTheme,
      elevatedButtonTheme: _elevatedButtonThemeData,
      outlinedButtonTheme: _outlinedButtonThemeData,
      textButtonTheme: _textButtonThemeData,
      textTheme: _textTheme,
      checkboxTheme: _checkboxThemeData,
      floatingActionButtonTheme: _floatingActionButtonThemeData,
    );
  }

  get _inputDecorationTheme {
    return InputDecorationTheme(
      contentPadding: const EdgeInsets.only(
        left: AppDimen.textLeftRightPadding,
        top: AppDimen.textTopBottomPadding,
        right: AppDimen.textLeftRightPadding,
        bottom: AppDimen.textTopBottomPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimen.textRadius),
      ),
      // labelStyle: GoogleFonts.poppins(
      //   fontStyle: FontStyle.normal,
      //   fontSize: 16,
      //   fontWeight: FontWeight.w500,
      // ),
      // errorStyle: GoogleFonts.poppins(
      //   fontStyle: FontStyle.normal,
      //   fontSize: 12,
      //   color: AppColors.error,
      // ),
    );
  }

  get _dropDownMenuTheme {
    return DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.only(
          left: AppDimen.textLeftRightPadding,
          top: AppDimen.textTopBottomPadding,
          right: AppDimen.textLeftRightPadding,
          bottom: AppDimen.textTopBottomPadding,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimen.textRadius),
        ),
      ),
    );
  }

  get _checkboxThemeData {
    return const CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimen.padding)),
      ),
    );
  }

  get _elevatedButtonThemeData {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimen.buttonRadius,
        ),
        elevation: 0,
        padding: AppDimen.buttonPadding,
        textStyle: GoogleFonts.poppins(
          fontStyle: FontStyle.normal,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
    );
  }

  get _outlinedButtonThemeData {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimen.buttonRadius,
        ),
        side: const BorderSide(color: AppColors.primary),
        padding: AppDimen.buttonPadding,
        textStyle: GoogleFonts.poppins(
          fontStyle: FontStyle.normal,
          fontSize: 15,
          color: AppColors.primary,
        ),
      ),
    );
  }

  get _textButtonThemeData {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: AppDimen.buttonRadius,
        ),
        padding: AppDimen.buttonPadding,
        textStyle: GoogleFonts.poppins(
          fontStyle: FontStyle.normal,
          fontSize: 15,
          color: AppColors.primary,
        ),
      ),
    );
  }

  get _textTheme {
    return TextTheme(
      titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      headlineSmall: GoogleFonts.poppins(),
      headlineMedium: GoogleFonts.poppins(),
      headlineLarge: GoogleFonts.poppins(),
      bodySmall: GoogleFonts.poppins(),
      bodyMedium: GoogleFonts.poppins(),
      bodyLarge: GoogleFonts.poppins(),
      displaySmall: GoogleFonts.poppins(),
      displayMedium: GoogleFonts.poppins(),
      displayLarge: GoogleFonts.poppins(),
      labelSmall: GoogleFonts.poppins(),
      labelMedium: GoogleFonts.poppins(),
      labelLarge: GoogleFonts.poppins(),
    );
  }

  get _floatingActionButtonThemeData {
    return const FloatingActionButtonThemeData(foregroundColor: Colors.white);
  }
}
