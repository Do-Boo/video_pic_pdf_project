import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mom_project/gets/g_theme_controller.dart';
import 'package:mom_project/theme/t_app_color.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeService = Get.put(ThemeService());
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const CustomTitleBarWrapper(child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find();
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 100,
              color: customTheme.containerColor,
              child: Center(
                child: Text(
                  'Themed Container',
                  style: TextStyle(color: customTheme.textColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Toggle Theme'),
              onPressed: () => themeService.toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTitleBarWrapper extends StatelessWidget {
  final Widget child;

  const CustomTitleBarWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !(Platform.isWindows || Platform.isMacOS)) {
      return child;
    }
    return Column(
      children: [
        const CustomTitleBar(),
        Expanded(child: child),
      ],
    );
  }
}

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      color: Colors.transparent,
      child: Row(
        children: [
          if (Platform.isMacOS) ...[
            const SizedBox(width: 76),
            const Expanded(child: DragToMoveArea(child: SizedBox())),
          ] else ...[
            const Expanded(child: DragToMoveArea(child: SizedBox())),
          ],
          if (Platform.isWindows) ...[
            _WindowsButton(
              icon: Icons.remove,
              onPressed: () => windowManager.minimize(),
            ),
            _WindowsButton(
              icon: Icons.crop_square,
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
            ),
            _WindowsButton(
              icon: Icons.close,
              onPressed: () => windowManager.close(),
            ),
          ],
          if (Platform.isMacOS) const SizedBox(width: 76),
        ],
      ),
    );
  }
}

class _WindowsButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _WindowsButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: double.infinity,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
      ),
    );
  }
}
