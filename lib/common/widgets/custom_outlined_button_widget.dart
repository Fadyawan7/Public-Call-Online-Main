import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/gradient_button_widget.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const CustomOutlinedButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GradientButtonWidget(
      onTap: onPressed,
      borderRadius: 25,
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.white,
              size: Dimensions.fontSizeExtraLarge,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
          ],
          Text(
            label,
            style: rubikSemiBold.copyWith(
              color: Colors.white,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
        ],
      ),
    );
  }
}
