import 'package:flutter/material.dart';
import 'package:mom_project/theme/t_app_color.dart';

class HoverText extends StatefulWidget {
  final String data;

  const HoverText({super.key, required this.data});

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Text(
        widget.data,
        style: TextStyle(
          fontSize: 18,
          // fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
          decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}
