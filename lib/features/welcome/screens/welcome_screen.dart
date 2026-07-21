import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:flutter_restaurant/common/widgets/gradient_button_widget.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
            child: SizedBox(
          width: 1170,
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(30),
                child: Image.asset(Images.logo, height: 200),
              ),
              const SizedBox(height: 30),
              Text(
                getTranslated('welcome', context)!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontSize: 32),
              ),
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Text(
                  '${getTranslated('welcome_to', context)!} ${AppConstants.appName}, ${getTranslated('please_login_or', context)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color:
                          Theme.of(context).hintColor.withValues(alpha: 0.7)),
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: CustomButtonWidget(
                  btnTxt: getTranslated('login', context),
                  onTap: () => RouterHelper.getLoginRoute(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeDefault,
                    top: 12),
                child: CustomButtonWidget(
                  btnTxt: getTranslated('signup', context),
                  onTap: () => RouterHelper.getCreateAccountRoute(),
                ),
              ),
              GradientButtonWidget(
                onTap: () => RouterHelper.getMainRoute(),
                height: 40,
                borderRadius: 10,
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: '${getTranslated('login_as_a', context)} ',
                      style: rubikRegular.copyWith(color: Colors.white70)),
                  TextSpan(
                      text: getTranslated('guest', context),
                      style: rubikSemiBold.copyWith(color: Colors.white)),
                ])),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
