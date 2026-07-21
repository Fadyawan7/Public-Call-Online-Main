import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';

enum SnackBarStatus { error, success, alert, info }

void showCustomSnackBarHelper(String? message,
    {SnackBarStatus status = SnackBarStatus.error, bool isToast = false}) {
  final Size size = MediaQuery.of(Get.context!).size;

  // Determine colors based on status
  late Color iconBgColor;
  late Color borderColor;
  late IconData iconData;
  late String statusLabel;

  switch (status) {
    case SnackBarStatus.error:
      iconBgColor = const Color(0xFFEF4444); // Red
      borderColor = const Color(0xFFEF4444);
      iconData = Icons.error_outline_rounded;
      statusLabel = 'Error';
      break;
    case SnackBarStatus.success:
      iconBgColor = const Color(0xFF10B981); // Green
      borderColor = const Color(0xFF10B981);
      iconData = Icons.check_circle_outline_rounded;
      statusLabel = 'Success';
      break;
    case SnackBarStatus.alert:
      iconBgColor = const Color(0xFFD97706); // Amber/Brown
      borderColor = const Color(0xFFD97706);
      iconData = Icons.warning_amber_rounded;
      statusLabel = 'Warning';
      break;
    case SnackBarStatus.info:
      iconBgColor = const Color(0xFF3B82F6); // Blue
      borderColor = const Color(0xFF3B82F6);
      iconData = Icons.info_outline_rounded;
      statusLabel = 'Info';
      break;
  }

  ScaffoldMessenger.of(Get.context!)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      elevation: 12,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2A2A2A),
              const Color(0xFF1F1F1F),
            ],
          ),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  color: iconBgColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              // Message Text
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusLabel,
                      style: rubikBold.copyWith(
                        color: iconBgColor,
                        fontSize: Dimensions.fontSizeSmall,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message ?? '',
                      style: rubikRegular.copyWith(
                        color: const Color(0xFFE5E7EB),
                        fontSize: Dimensions.fontSizeDefault,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      margin: ResponsiveHelper.isDesktop(Get.context!)
          ? EdgeInsets.only(
              right: size.width * 0.7,
              bottom: Dimensions.paddingSizeExtraSmall,
              left: Dimensions.paddingSizeExtraSmall)
          : EdgeInsets.only(
              bottom: size.height * 0.08,
              left: Dimensions.paddingSizeLarge,
              right: Dimensions.paddingSizeLarge),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 4),
    ));
}
