import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primaryPink;
  final Color secondaryPeach;
  final Color bgWhite;
  final Color cardWhite;
  final Color textDark;
  final Color textLight;

  const AppColors({
    required this.primaryPink,
    required this.secondaryPeach,
    required this.bgWhite,
    required this.cardWhite,
    required this.textDark,
    required this.textLight,
  });

  @override
  AppColors copyWith({
    Color? primaryPink,
    Color? secondaryPeach,
    Color? bgWhite,
    Color? cardWhite,
    Color? textDark,
    Color? textLight,
  }) {
    return AppColors(
      primaryPink: primaryPink ?? this.primaryPink,
      secondaryPeach: secondaryPeach ?? this.secondaryPeach,
      bgWhite: bgWhite ?? this.bgWhite,
      cardWhite: cardWhite ?? this.cardWhite,
      textDark: textDark ?? this.textDark,
      textLight: textLight ?? this.textLight,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primaryPink: Color.lerp(primaryPink, other.primaryPink, t)!,
      secondaryPeach: Color.lerp(secondaryPeach, other.secondaryPeach, t)!,
      bgWhite: Color.lerp(bgWhite, other.bgWhite, t)!,
      cardWhite: Color.lerp(cardWhite, other.cardWhite, t)!,
      textDark: Color.lerp(textDark, other.textDark, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
    );
  }
}

class AppTheme {
  
  static const lightColors = AppColors(
    primaryPink: Color(0xFFFF7B89),
    secondaryPeach: Color(0xFFFFB5C2),
    bgWhite: Color(
      0xFFFDFBF7,
    ), 
    cardWhite: Color(0xFFFFFFFF),
    textDark: Color(0xFF2D2D2D),
    textLight: Color(0xFF8E8E93),
  );

  
  static const darkColors = AppColors(
    primaryPink: Color(0xFFE55B7E), 
    secondaryPeach: Color(0xFFFFB5C2), 
    bgWhite: Color(0xFF1E1C22), 
    cardWhite: Color(0xFF2C2A30), 
    textDark: Color(0xFFF7F7F7), 
    textLight: Color(0xFFA1A0A5), 
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightColors.bgWhite,
      primaryColor: lightColors.primaryPink,
      extensions: [lightColors],
      colorScheme: ColorScheme.light(
        primary: lightColors.primaryPink,
        secondary: lightColors.secondaryPeach,
        surface: lightColors.cardWhite,
        onSurface: lightColors.textDark,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: lightColors.textDark,
        displayColor: lightColors.textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightColors.bgWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightColors.primaryPink),
        titleTextStyle: TextStyle(
          color: lightColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightColors.cardWhite,
        selectedItemColor: lightColors.primaryPink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColors.primaryPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: lightColors.primaryPink.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: lightColors.primaryPink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColors.cardWhite,
        hintStyle: TextStyle(color: lightColors.textLight),
        labelStyle: TextStyle(color: lightColors.textLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: lightColors.secondaryPeach.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: lightColors.primaryPink, width: 2),
        ),
        prefixIconColor: lightColors.primaryPink,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkColors.bgWhite,
      primaryColor: darkColors.primaryPink,
      extensions: [darkColors],
      colorScheme: ColorScheme.dark(
        primary: darkColors.primaryPink,
        secondary: darkColors.secondaryPeach,
        surface: darkColors.cardWhite,
        onSurface: darkColors.textDark,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkColors.textDark,
        displayColor: darkColors.textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkColors.bgWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkColors.primaryPink),
        titleTextStyle: TextStyle(
          color: darkColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkColors.cardWhite,
        selectedItemColor: darkColors.primaryPink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColors.primaryPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: darkColors.primaryPink.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: darkColors.primaryPink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColors.cardWhite,
        hintStyle: TextStyle(color: darkColors.textLight),
        labelStyle: TextStyle(color: darkColors.textLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: darkColors.secondaryPeach.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: darkColors.primaryPink, width: 2),
        ),
        prefixIconColor: darkColors.primaryPink,
      ),
    );
  }
}
