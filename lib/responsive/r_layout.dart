import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mom_project/gets/g_context_controller.dart';
import 'dart:ui' as ui;

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScaffold;
  final Widget tabletScaffold;
  final Widget desktopScaffold;

  const ResponsiveLayout({super.key, required this.mobileScaffold, required this.tabletScaffold, required this.desktopScaffold});

  @override
  Widget build(BuildContext context) {
    final ResponsiveController controller = Get.find<ResponsiveController>();

    return LayoutBuilder(builder: (context, constraints) {
      final display = ui.window.display;
      final width = display.size.width / display.devicePixelRatio;
      final height = display.size.height / display.devicePixelRatio;

      controller.displaySize(height, width);
      controller.updateScreenSize(constraints.maxHeight, constraints.maxWidth);

      if (constraints.maxWidth < 768) {
        return mobileScaffold;
      } else if (constraints.maxWidth < 1024) {
        return tabletScaffold;
      } else {
        return desktopScaffold;
      }
    });
  }
}
