import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mom_project/theme/t_app_theme.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  final List<bool> _isHovered = List.filled(6, false);

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    final navTitles = ["HOME", "ALL FILES", "VIDEOS", "PHOTOS", "RECENT", "SETTINGS"];
    final navIcons = [
      HugeIcons.strokeRoundedHome09,
      HugeIcons.strokeRoundedFolder01,
      HugeIcons.strokeRoundedVideo01,
      HugeIcons.strokeRoundedImage02,
      HugeIcons.strokeRoundedClock01,
      HugeIcons.strokeRoundedSettings02,
    ];

    final navActions = [
      () => print("Home tapped"),
      () => print("All Files tapped"),
      () => print("Videos tapped"),
      () => print("Photos tapped"),
      () => print("Recent tapped"),
      () => print("Settings tapped")
    ];

    return Container(
      width: 104,
      color: customTheme.containerColor,
      child: Column(
        children: [
          const AspectRatio(
            aspectRatio: 1 / 1,
            child: Icon(Icons.abc_outlined),
          ),
          for (int i = 0; i < navIcons.length; i++) ...[
            AspectRatio(
              aspectRatio: 16 / 10,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered[i] = true),
                onExit: (_) => setState(() => _isHovered[i] = false),
                child: GestureDetector(
                  onTap: navActions[i],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 200),
                          tween: Tween(begin: 1.0, end: _isHovered[i] ? 1.2 : 1.0),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: HugeIcon(icon: navIcons[i], color: customTheme.textColor.withOpacity(0.5)),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(navTitles[i], style: TextStyle(color: customTheme.textColor.withOpacity(0.5))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
