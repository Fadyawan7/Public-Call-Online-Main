import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_alert_dialog_widget.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/auth/widgets/existing_account_bottom_sheet.dart';
import 'package:flutter_restaurant/features/profile/domain/models/userinfo_model.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class SocialLoginWidget extends StatefulWidget {
  const SocialLoginWidget({super.key});

  @override
  State<SocialLoginWidget> createState() => _SocialLoginWidgetState();
}

class _SocialLoginWidgetState extends State<SocialLoginWidget> {
  void route(
      bool isRoute,
      String? token,
      String? errorMessage,
      String? tempToken,
      UserInfoModel? userInfoModel,
      String? socialLoginMedium) async {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final ProfileProvider profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    if (isRoute) {
      if (token != null) {
        await profileProvider.getUserInfo(true);
        // Ensure profileProvider.userInfoModel is not null before accessing its properties
        if (profileProvider.userInfoModel != null) {
          if (profileProvider.userInfoModel!.countryId == -1) {
            RouterHelper.getProfileRoute('splash',
                action: RouteAction.pushReplacement);
          } else {
            RouterHelper.getMainRoute(
                action: RouteAction.pushNamedAndRemoveUntil);
          }
        } else {
          // Handle case where userInfoModel is null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User information is not available.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (tempToken != null) {
        // Redirect to OTP registration screen
        RouterHelper.getOtpRegistrationScreen(
          tempToken,
          authProvider.socialEmail ?? authProvider.googleAccount?.email ?? '',
          userName: authProvider.socialName ??
              authProvider.googleAccount?.displayName ??
              '',
        );
      } else if (userInfoModel != null) {
        // Show existing account dialog
        ResponsiveHelper.showDialogOrBottomSheet(
          context,
          isDismissible: false,
          CustomAlertDialogWidget(
            width: ResponsiveHelper.isDesktop(context)
                ? MediaQuery.of(context).size.width * 0.3
                : null,
            child: ExistingAccountBottomSheet(
              userInfoModel: userInfoModel,
              loginMedium: socialLoginMedium!,
            ),
          ),
        );
      } else {
        // Show error message if no valid condition is met
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Unable to complete social login.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Show error message if isRoute is false
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Unable to complete social login.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIos = defaultTargetPlatform == TargetPlatform.iOS;

    return Consumer<AuthProvider>(builder: (context, authProvider, _) {
      final bool isBusy =
          authProvider.isLoading || authProvider.isSocialAuthLoading;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: isBusy
                  ? null
                  : () => isIos
                      ? authProvider.loginWithApple(route)
                      : authProvider.loginWithGoogle(route),
              child: SocialLoginButtonWidget(
                text: isIos
                    ? getTranslated('continue_with_apple', context)!
                    : getTranslated('continue_with_google', context)!,
                image: isIos ? Images.appleLogo : Images.google,
                color: isIos
                    ? Theme.of(context).textTheme.bodyMedium?.color
                    : null,
              ),
            ),
          ),
          Expanded(child: Container()),
        ],
      );
    });
  }
}

class SocialLoginButtonWidget extends StatelessWidget {
  final String? text;
  final String image;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  const SocialLoginButtonWidget({
    super.key,
    this.text,
    required this.image,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            color: color,
            height: ResponsiveHelper.isDesktop(context)
                ? 25
                : ResponsiveHelper.isTab(context)
                    ? 20
                    : 15,
            width: ResponsiveHelper.isDesktop(context)
                ? 25
                : ResponsiveHelper.isTab(context)
                    ? 20
                    : 15,
          ),
          if (text != null) ...[
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              text!,
              style: rubikSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            )
          ],
        ],
      ),
    );
  }
}
