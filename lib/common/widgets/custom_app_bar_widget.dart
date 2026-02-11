import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:go_router/go_router.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
    final BuildContext? context;

  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? actionView;
  final bool centerTitle;
  final bool isTransparent;
  final double elevation;
  final Widget? leading;
  final Color? titleColor;

  const CustomAppBarWidget({
    super.key,
    required this.title,
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.actionView,    this.context,

    this.centerTitle = true,
    this.isTransparent = false,
    this.elevation = 0,
    this.leading,
    this.titleColor,
  });

  void _handleBack(BuildContext context) {
    if (onBackPressed != null) {
      onBackPressed!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      // Optional fallback (change '/' if your home route is different)
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      centerTitle: centerTitle,
      backgroundColor:
          isTransparent ? Colors.transparent : Theme.of(context).primaryColor,
      title: FittedBox(
        child: Stack(
          children: [
            // Border text
            Text(
              title ?? '',
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
            // Fill text
            Text(
              title ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
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
      leading: isBackButtonExist
          ? (leading != null
              ? GestureDetector(
                  onTap: () => _handleBack(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: leading,
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: titleColor ?? Colors.red,
                  onPressed: () => _handleBack(context),
                ))
          : const SizedBox(),
      actions: actionView != null
          ? [
              Padding(
                padding:
                    const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: actionView!,
              )
            ]
          : [],
    );
  }

  @override
  Size get preferredSize => Size(
        double.maxFinite,
        ResponsiveHelper.isDesktop(Get.context) ? 100 : 50,
      );
}
