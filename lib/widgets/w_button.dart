import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;
  final Widget? child;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsets? padding;

  const Button({super.key, this.color, this.border, this.child, this.borderRadius, this.onPressed, this.padding});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).primaryColor,
          borderRadius: borderRadius ?? BorderRadius.circular(0),
          border: border ?? const Border(),
        ),
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(0),
          onTap: onPressed,
          child: child,
        ),
      ),
    );
  }
}
