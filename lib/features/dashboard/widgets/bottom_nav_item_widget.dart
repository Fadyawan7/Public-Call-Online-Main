import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final Function? onTap;
  final bool isSelected;
  final String? imageIcon;

  const BottomNavItemWidget({
    super.key,
    this.onTap,
    this.isSelected = false,
    required this.title,
     this.icon,
    this.imageIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔥 Show Image if imageIcon is provided, otherwise show Icon
            imageIcon != null && imageIcon!.isNotEmpty
                ? CustomAssetImageWidget(
                    imageIcon!,
                    height: 25,
                    width: 25,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor,
                  )
                : Icon(
                    icon,
                    size: 28,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor,
                  ),

            SizedBox(
                height: isSelected
                    ? Dimensions.paddingSizeExtraSmall
                    : Dimensions.paddingSizeSmall),

            if (isSelected)
              Text(
                title,
                style: rubikBold.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
