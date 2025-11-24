import 'package:flutter/material.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';

class ListTileWidget extends StatelessWidget {
  final IconData? iconData; // For Icons
  final String? assetImage; // For Asset Images
  final String? mainTxt;
  final String? subTxt;

  const ListTileWidget({
    super.key,
    this.iconData,
    this.assetImage,
    this.mainTxt,
    this.subTxt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          // ---- ICON OR IMAGE ----
          if (iconData != null)
            Icon(
              iconData,
              size: Dimensions.fontSizeOverLarge,
              color: Theme.of(context).hintColor,
            )
          else if (assetImage != null)
            Image.asset(
              assetImage!,
              height: 28,
              width: 28,
              // color: Theme.of(context).hintColor,
            ),

          const SizedBox(width: Dimensions.paddingSizeDefault),

          // ---- TEXT SECTION ----
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated('$mainTxt', context)!,
                style: rubikMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                '$subTxt',
                style: rubikBold.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
            ],
          )
        ],
      ),
    );
  }
}
