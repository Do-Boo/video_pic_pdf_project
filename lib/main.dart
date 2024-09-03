import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mom_project/gets/g_nas_file_controller.dart';
import 'package:mom_project/responsive/r_desktop_scaffold.dart';
import 'package:mom_project/responsive/r_layout.dart';
import 'package:mom_project/responsive/r_mobile_scaffold.dart';
import 'package:mom_project/responsive/r_tablet_scaffold.dart';
import 'package:mom_project/theme/t_app_color.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  final authController = Get.put(AuthController());
  await authController.login();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: BindingsBuilder(() {
        Get.put(SynologyFileListController());
      }),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const CustomTitleBarWrapper(child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileScaffold: MobileScaffold(),
      tabletScaffold: TabletScaffold(),
      desktopScaffold: DesktopScaffold(),
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
      color: Theme.of(context).primaryColor,
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
