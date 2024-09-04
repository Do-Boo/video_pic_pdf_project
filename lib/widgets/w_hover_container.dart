import 'package:flutter/material.dart';
import 'package:mom_project/theme/t_app_theme.dart';

class HoverContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const HoverContainer({super.key, required this.child, this.padding, this.borderRadius});

  @override
  State<HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<HoverContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          color: customTheme.containerColor,
          border: Border.all(color: customTheme.textColor.withOpacity(_isHovered ? 0.5 : 0), width: 1),
        ),
        child: widget.child,
      ),
    );
  }
}
