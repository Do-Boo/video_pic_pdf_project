import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeService extends GetxService {
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

class ResponsiveController extends GetxController {
  final _displayHeight = 0.0.obs;
  final _displayWidth = 0.0.obs;
  final _screenHeight = 0.0.obs;
  final _screenWidth = 0.0.obs;

  void displaySize(double height, double width) {
    _displayHeight.value = height;
    _displayWidth.value = width;
  }

  void updateScreenSize(double height, double width) {
    _screenHeight.value = height;
    _screenWidth.value = width;
  }

  double get screenHeight => _screenHeight.value;
  double get screenWidth => _screenWidth.value;
  double get screenRate => _screenWidth.value / _displayWidth.value / (kIsWeb ? 2 : 1);
}
