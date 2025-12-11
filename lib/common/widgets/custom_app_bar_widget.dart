import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:go_router/go_router.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final BuildContext? context;
  final Widget? actionView;
  final bool centerTitle;
  final bool isTransparent;
  final double elevation;
  final Widget? leading;
  final Color? titleColor;

  const CustomAppBarWidget(
      {super.key,
      required this.title,
      this.isBackButtonExist = true,
      this.onBackPressed,
      this.context,
      this.actionView,
      this.centerTitle = true,
      this.isTransparent = false,
      this.elevation = 0,
      this.leading,
      this.titleColor});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: FittedBox(
        child: Stack(
          children: [
            // BORDER
            Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 18,
                height: 1.2,
                letterSpacing: 1.5,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Theme.of(context).primaryColor,
              ),
            ),

            // FILL
            Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 18,
                height: 1.2,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      centerTitle: centerTitle,
      leading: isBackButtonExist
          ? (leading != null
              ? GestureDetector(
                  onTap: () =>
                      onBackPressed != null ? onBackPressed!() : context.pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: leading,
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: titleColor ?? Colors.red,
                  onPressed: () =>
                      onBackPressed != null ? onBackPressed!() : context.pop(),
                ))
          : (leading != null
              ? GestureDetector(
                  onTap: () =>
                      onBackPressed != null ? onBackPressed!() : context.pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: leading,
                  ),
                )
              : const SizedBox()),

      actions: actionView != null
          ? [
              Padding(
                padding:
                    const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: actionView!,
              )
            ]
          : [],
      // backgroundColor:
      //     isTransparent ? Colors.transparent : Theme.of(context).primaryColor,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => Size(
      double.maxFinite, ResponsiveHelper.isDesktop(Get.context) ? 100 : 50);
}
