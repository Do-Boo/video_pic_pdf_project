import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mom_project/gets/g_theme_controller.dart';
import 'package:mom_project/pages/p_all_files_page.dart';
import 'package:mom_project/theme/t_app_color.dart';
import 'package:mom_project/widgets/w_navigationbar.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomNavigationBar(),
          Expanded(
            flex: 10,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: const Stack(
                children: [
                  // Placeholder(),
                  FilesPage(),
                ],
              ),
            ),
          ),
          Container(width: 352, color: customTheme.containerColor),
        ],
      ),
    );
  }
}
