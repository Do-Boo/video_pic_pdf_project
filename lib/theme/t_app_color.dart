import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textLight = Color(0xFF000000);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color containerLight = Color(0xFFE0E0E0);
  static const Color containerDark = Color(0xFF424242);
}

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color containerColor;
  final Color textColor;

  const CustomThemeExtension({
    required this.containerColor,
    required this.textColor,
  });

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? containerColor,
    Color? textColor,
  }) {
    return CustomThemeExtension(
      containerColor: containerColor ?? this.containerColor,
      textColor: textColor ?? this.textColor,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
    ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      containerColor: Color.lerp(containerColor, other.containerColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
    );
  }
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textLight),
    ),
    extensions: const [
      CustomThemeExtension(
        containerColor: AppColors.containerLight,
        textColor: AppColors.textLight,
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textDark),
    ),
    extensions: const [
      CustomThemeExtension(
        containerColor: AppColors.containerDark,
        textColor: AppColors.textDark,
      ),
    ],
  );
}
