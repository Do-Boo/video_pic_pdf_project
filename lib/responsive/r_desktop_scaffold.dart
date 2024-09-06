import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mom_project/gets/g_context_controller.dart';
import 'package:mom_project/pages/p_all_files_page.dart';
import 'package:mom_project/pages/p_all_videos_page.dart';
import 'package:mom_project/theme/t_app_theme.dart';
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
          const SizedBox(width: 106, child: CustomNavigationBar()),
          Expanded(
            flex: 15,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: const Stack(
                children: [
                  VideosPage(),
                ],
              ),
            ),
          ),
          Expanded(flex: 4, child: Container(color: customTheme.containerColor)),
        ],
      ),
    );
  }
}
