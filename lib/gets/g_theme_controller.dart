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
