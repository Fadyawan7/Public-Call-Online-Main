import 'package:flutter/material.dart';

class GradientButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double borderRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool transparent;
  final List<Color>? gradientColors;

  const GradientButtonWidget({
    super.key,
    required this.onTap,
    required this.child,
    this.borderRadius = 12,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.margin,
    this.transparent = false,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null;
    final List<Color> colors = gradientColors ??
        [
          Theme.of(context).primaryColor,
          Theme.of(context).secondaryHeaderColor,
        ];
    final Gradient gradient = LinearGradient(colors: colors);

    final BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: (!transparent && !disabled) ? gradient : null,
      color: (transparent)
          ? Colors.transparent
          : (disabled ? Theme.of(context).disabledColor : null),
    );

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
