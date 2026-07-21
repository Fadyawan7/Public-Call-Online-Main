import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/gradient_button_widget.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/freelancer/domain/models/freelancer_model.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/features/menu/widgets/portion_widget.dart';
import 'package:flutter_restaurant/features/menu/widgets/sign_out_dialog_widget.dart';
import 'package:flutter_restaurant/features/menu/widgets/theme_switch_button_widget.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/app_localization.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class OptionsWidget extends StatefulWidget {
  final Function? onTap;
  const OptionsWidget({super.key, required this.onTap});

  @override
  State<OptionsWidget> createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsWidget> {
  FreelancerModel? _freelancer;
  int? _loadedFreelancerId;
  bool _isLoadingFreelancer = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFreelancerCategoriesIfNeeded();
  }

  Future<void> _loadFreelancerCategoriesIfNeeded() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final userInfo = profileProvider.userInfoModel;

    if (userInfo == null ||
        userInfo.userType != 'freelancer' ||
        userInfo.id == null) {
      return;
    }

    if (_loadedFreelancerId == userInfo.id) {
      return;
    }

    _loadedFreelancerId = userInfo.id;
    setState(() {
      _isLoadingFreelancer = true;
    });

    await Provider.of<FreelancerProvider>(context, listen: false)
        .getFreelancerDetails(userInfo.id.toString(), isApiCheck: false);

    if (!mounted) {
      return;
    }

    setState(() {
      _freelancer = Provider.of<FreelancerProvider>(context, listen: false)
          .freelancerDetails;
      _isLoadingFreelancer = false;
    });
  }

  List<String> _buildCategoryItems() {
    final apiCategories = _freelancer?.categories;

    if (apiCategories != null && apiCategories.isNotEmpty) {
      return apiCategories
          .map((category) => category.name?.trim() ?? '')
          .where((name) => name.isNotEmpty && name.toLowerCase() != 'null')
          .toList();
    }

    final String? categoryName = _freelancer?.category_name?.trim();
    final String? category = _freelancer?.category?.trim();

    final String fallback = (categoryName != null &&
            categoryName.isNotEmpty &&
            categoryName.toLowerCase() != 'null')
        ? categoryName
        : (category != null &&
                category.isNotEmpty &&
                category.toLowerCase() != 'null')
            ? category
            : '';

    if (fallback.isEmpty) {
      return [];
    }

    final categories = fallback
        .split(RegExp(r'[,|/]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
        .toList();

    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final categoryItems = _buildCategoryItems();
    final bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    return Consumer<AuthProvider>(
        builder: (context, authProvider, _) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Ink(
                padding:
                    const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                child: Column(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (categoryItems.isEmpty)
                          SizedBox.shrink()
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                child: Text('My Category',
                                    style: rubikSemiBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge)),
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        spreadRadius: 0.4,
                                        blurRadius: 1)
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeDefault),
                                margin: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: _isLoadingFreelancer
                                          ? const Center(
                                              child: SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            )
                                          : Wrap(
                                              spacing: 5,
                                              runSpacing: 5,
                                              alignment: WrapAlignment.start,
                                              children:
                                                  categoryItems.map((item) {
                                                return Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFEAE6FA)
                                                            .withAlpha(900),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault),
                          child: Text(getTranslated('general', context)!,
                              style: rubikSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 5)
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault),
                          margin: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          child: Consumer<ProfileProvider>(
                            builder: (context, profileProvider, child) {
                              return Column(children: [
                                PortionWidget(
                                    imageIcon: Images.profileSvg,
                                    title: getTranslated('profile', context)!,
                                    onRoute: () =>
                                        RouterHelper.getProfileRoute('main')),

                                if (profileProvider.userInfoModel != null &&
                                    profileProvider.userInfoModel!.userType ==
                                        'freelancer') ...[
                                  // Status Toggle Widget
                                  InkWell(
                                    onTap:
                                        null, // Disable tap as the switch handles interaction
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: Dimensions.paddingSizeSmall),
                                      child: Row(children: [
                                        Container(
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeExtraSmall),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .shadowColor
                                                .withValues(alpha: 0.1),
                                          ),
                                          child: Icon(Icons.work_outline,
                                              size: 16,
                                              color:
                                                  Theme.of(context).hintColor),
                                        ),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeSmall),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault),
                                              Row(
                                                children: [
                                                  Text('Work Status',
                                                      style: rubikRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge)),
                                                  const Spacer(),
                                                  const ThemeSwitchButtonWidget(),
                                                ],
                                              ),
                                              Divider(
                                                color: Theme.of(context)
                                                    .hintColor
                                                    .withValues(alpha: 0.1),
                                              ),
                                            ])),
                                      ]),
                                    ),
                                  ),

                                  // PortionWidget(
                                  //     icon: Icons.calendar_month,
                                  //     title: getTranslated(
                                  //         'my_bookings', context)!,
                                  //     onRoute: () => RouterHelper
                                  //         .getFreelancerBookingRoute()),
                                  // PortionWidget(
                                  //     icon: Iconsax.gallery,
                                  //     title: getTranslated(
                                  //         'my_portfolio', context)!,
                                  //     onRoute: () => RouterHelper
                                  //         .getFreelancerPortfolioListRoute()),
                                ],
                                PortionWidget(
                                    icon: Iconsax.home,
                                    title:
                                        getTranslated('my_address', context)!,
                                    onRoute: () =>
                                        RouterHelper.getAddressRoute()),
                                PortionWidget(
                                    icon: Icons.change_circle,
                                    title: getTranslated(
                                        'change_password', context)!,
                                    onRoute: () =>
                                        RouterHelper.getChangePasswordRoute()),

                                PortionWidget(
                                    imageIcon: Images.notification,
                                    title:
                                        getTranslated('notification', context)!,
                                    onRoute: () =>
                                        RouterHelper.getNotificationRoute()),

                                Consumer<ProfileProvider>(
                                  builder: (context, profileProvider, child) {
                                    String? applicationStatus = profileProvider
                                            .userInfoModel
                                            ?.freelancerRequestStatus ??
                                        '';
                                    String? applicationStatusNote =
                                        profileProvider.userInfoModel
                                                ?.freelancerRequestNote ??
                                            '';
                                    final bool canRouteToApply =
                                        applicationStatus.isEmpty ||
                                            (applicationStatus != 'approved' &&
                                                applicationStatus != 'pending');
                                    final Color applicationStatusColor =
                                        (applicationStatus.isEmpty ||
                                                applicationStatus ==
                                                    'no-request')
                                            ? Colors.green
                                            : ColorResources.getStatusTextColor(
                                                applicationStatus);

                                    return PortionWidget(
                                      iconColor: applicationStatusColor,
                                      icon: Icons.person_add_sharp,
                                      textColor: applicationStatusColor,
                                      imageIcon: Images.addressSvg,
                                      title:
                                          'Apply For Worker - ( ${applicationStatus.toCapitalized().replaceAll('-', ' ')} )',
                                      suffix: (applicationStatus ==
                                                  'needed_more_data' ||
                                              applicationStatus == 'rejected')
                                          ? applicationStatusNote
                                          : null,
                                      onRoute: canRouteToApply
                                          ? () => RouterHelper
                                              .getApplyFreelancerRoute()
                                          : null,
                                    );
                                  },
                                )

                                // PortionWidget(imageIcon: Images.languageSvg, title: getTranslated('language', context)!, onRoute:()=> RouterHelper.getLanguageRoute(true), hideDivider: true),
                              ]);
                            },
                          ),
                        )
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault),
                          child: Text(getTranslated('menu_more', context)!,
                              style: rubikSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 5)
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault),
                          margin: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          child: Column(children: [
                            PortionWidget(
                                imageIcon: Images.supportSvg,
                                title:
                                    getTranslated('help_and_support', context)!,
                                onRoute: () => RouterHelper.getSupportRoute()),
                            PortionWidget(
                                imageIcon: Images.documentSvg,
                                title:
                                    getTranslated('privacy_policy', context)!,
                                onRoute: () => RouterHelper.getPolicyRoute()),
                            PortionWidget(
                                imageIcon: Images.documentAltSvg,
                                title: getTranslated(
                                    'terms_and_condition', context)!,
                                onRoute: () => RouterHelper.getTermsRoute()),
                            PortionWidget(
                                imageIcon: Images.infoSvg,
                                title: getTranslated('about_us', context)!,
                                onRoute: () => RouterHelper.getAboutUsRoute()),
                            isLoggedIn
                                ? PortionWidget(
                                    iconColor: Theme.of(context).primaryColor,
                                    icon: Icons.delete,
                                    imageIcon: null,
                                    title: getTranslated(
                                        'delete_account', context)!,
                                    onRoute: () => showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (dialogContext) {
                                        return Consumer<AuthProvider>(
                                          builder: (context, authProvider, _) {
                                            return Dialog(
                                              insetPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 420),
                                                padding: const EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeLarge),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Theme.of(dialogContext)
                                                      .cardColor,
                                                ),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 64,
                                                        height: 64,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Theme.of(
                                                                  dialogContext)
                                                              .colorScheme
                                                              .primary
                                                              .withValues(
                                                                  alpha: 0.12),
                                                        ),
                                                        child: Icon(
                                                            Icons
                                                                .delete_outline_rounded,
                                                            color: Theme.of(
                                                                    dialogContext)
                                                                .colorScheme
                                                                .primary,
                                                            size: 32),
                                                      ),
                                                      const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeDefault),
                                                      Text(
                                                        getTranslated(
                                                                'are_you_sure_to_delete_account',
                                                                dialogContext) ??
                                                            '',
                                                        style: rubikBold.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeSmall),
                                                      Text(
                                                        getTranslated(
                                                                'it_will_remove_your_all_information',
                                                                dialogContext) ??
                                                            '',
                                                        style: rubikRegular
                                                            .copyWith(
                                                          color: Theme.of(
                                                                  dialogContext)
                                                              .hintColor,
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeLarge),
                                                      Row(children: [
                                                        Expanded(
                                                          child:
                                                              GradientButtonWidget(
                                                            onTap: authProvider
                                                                    .isLoading
                                                                ? null
                                                                : () => Navigator
                                                                    .pop(
                                                                        dialogContext),
                                                            height: 46,
                                                            borderRadius: 12,
                                                            child: Text(
                                                              getTranslated(
                                                                      'no',
                                                                      dialogContext) ??
                                                                  'No',
                                                              style: rubikMedium
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeSmall),
                                                        Expanded(
                                                          child:
                                                              GradientButtonWidget(
                                                            onTap: authProvider
                                                                    .isLoading
                                                                ? null
                                                                : () => authProvider
                                                                    .deleteUser(),
                                                            height: 46,
                                                            borderRadius: 12,
                                                            child: authProvider
                                                                    .isLoading
                                                                ? const SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child: CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2,
                                                                        color: Colors
                                                                            .white),
                                                                  )
                                                                : Text(
                                                                    getTranslated(
                                                                            'yes',
                                                                            dialogContext) ??
                                                                        'Yes',
                                                                    style: rubikMedium
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.white)),
                                                          ),
                                                        ),
                                                      ]),
                                                    ]),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  )
                                : const SizedBox(),
                            InkWell(
                              onTap: () {
                                if (authProvider.isLoggedIn()) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (_) => const SignOutDialogWidget(),
                                  );
                                } else {
                                  RouterHelper.getLoginRoute();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeSmall),
                                child: Row(children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeExtraSmall),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.1),
                                    ),
                                    child: CustomAssetImageWidget(
                                      isLoggedIn
                                          ? Images.logoutSvg
                                          : Images.login,
                                      height: 16,
                                      width: 16,
                                      color: isLoggedIn
                                          ? null
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Text(
                                      getTranslated(
                                          isLoggedIn ? 'logout' : 'login',
                                          context)!,
                                      style: rubikRegular)
                                ]),
                              ),
                            ),
                          ]),
                        )
                      ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                      '${getTranslated('v', context)} ${AppConstants.appVersion}',
                      style: rubikRegular.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.color
                            ?.withValues(alpha: 0.4),
                      )),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                ]),
              ),
            ));
  }
}
