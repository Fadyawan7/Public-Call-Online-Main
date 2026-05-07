import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/gradient_button_widget.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:provider/provider.dart';

class SignOutDialogWidget extends StatelessWidget {
  const SignOutDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, child) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).cardColor,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.12),
              ),
              child: Icon(Icons.logout_rounded,
                  color: Theme.of(context).primaryColor, size: 32),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              getTranslated('want_to_sign_out', context) ?? '',
              style: rubikBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'You can sign in again anytime.',
              style: rubikRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeDefault,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Row(children: [
              Expanded(
                child: GradientButtonWidget(
                  onTap: auth.isLoading ? null : () => Navigator.pop(context),
                  height: 46,
                  borderRadius: 12,
                  child: Text(
                    getTranslated('no', context) ?? 'No',
                    style: rubikMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: GradientButtonWidget(
                  onTap: auth.isLoading
                      ? null
                      : () {
                          Provider.of<AuthProvider>(context, listen: false)
                              .clearSharedData(context)
                              .then((condition) {
                            Navigator.pop(context);
                            RouterHelper.getLoginRoute(
                                action: RouteAction.pushNamedAndRemoveUntil);
                          });
                        },
                  height: 46,
                  borderRadius: 12,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          getTranslated('yes', context) ?? 'Yes',
                          style: rubikMedium.copyWith(color: Colors.white),
                        ),
                ),
              ),
            ]),
          ]),
        ),
      );
    });
  }
}
