import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryLight = Color(0xFFd6d6d8);
  static const Color primaryDark = Color(0xFF1d1b22);
  static const Color backgroundLight = Color(0xFFd6d6d8);
  static const Color backgroundDark = Color(0xFF1d1b22);
  static const Color textLight = Color(0xFF000000);
  static const Color textDark = Color(0xFFd6d6d8);
  static const Color containerLight = Color(0xFFd6d6d8);
  static const Color containerDark = Color(0xFF26262e);
  static const Color iconColorLight = Color(0xFF26262e);
  static const Color iconColorDark = Color(0xFF26262e);
}

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color containerColor;
  final Color textColor;
  final Color iconColor;

  const CustomThemeExtension({required this.iconColor, required this.containerColor, required this.textColor});

  @override
  ThemeExtension<CustomThemeExtension> copyWith({Color? containerColor, Color? textColor, Color? iconColor}) {
    return CustomThemeExtension(
      containerColor: containerColor ?? this.containerColor,
      textColor: textColor ?? this.textColor,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      containerColor: Color.lerp(containerColor, other.containerColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
    );
  }
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryLight,
    hintColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textLight),
    ),
    extensions: const [
      CustomThemeExtension(
        containerColor: AppColors.containerLight,
        textColor: AppColors.textLight,
        iconColor: AppColors.iconColorLight,
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    hintColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textDark),
    ),
    extensions: const [
      CustomThemeExtension(
        containerColor: AppColors.containerDark,
        textColor: AppColors.textDark,
        iconColor: AppColors.iconColorDark,
      ),
    ],
  );
}
