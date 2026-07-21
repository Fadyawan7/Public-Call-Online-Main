import 'package:flutter/material.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';

class GradientCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final List<Color>? gradientColors;

  const GradientCardWidget({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault),
    this.margin,
    this.borderRadius = Dimensions.radiusDefault,
    this.backgroundColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = gradientColors ??
        [
          Theme.of(context).primaryColor.withValues(alpha: 0.05),
          Theme.of(context).canvasColor,
        ];

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        // gradient:
        //     backgroundColor == null ? LinearGradient(colors: colors) : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }
}
