import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_restaurant/common/widgets/not_logged_in_widget.dart';
import 'package:flutter_restaurant/features/apply_freelancer/domain/models/apply_freelancer_model.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/features/freelancer_portfolio/providers/freelancer_portfolio_provider.dart';
import 'package:flutter_restaurant/features/profile/domain/models/userinfo_model.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/features/profile/widgets/profile_custom_painter_widget.dart';
import 'package:flutter_restaurant/features/profile/widgets/profile_shimmer_widget.dart';
import 'package:flutter_restaurant/features/profile/widgets/profile_textfield_widget.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/image_utils.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ApplyFreelancerScreen extends StatefulWidget {
  const ApplyFreelancerScreen({super.key});

  @override
  State<ApplyFreelancerScreen> createState() => _ApplyFreelancerScreenState();
}

class _ApplyFreelancerScreenState extends State<ApplyFreelancerScreen> {
  FocusNode? _firstNameFocus;
  FocusNode? _aboutMe;
  FocusNode? _phoneNumberFocus;

  TextEditingController? _firstNameController;
  TextEditingController? _aboutMeController;
  TextEditingController? _perhourController;
  TextEditingController? _perdayChargesController;
  TextEditingController? _perkmChargesController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _customCategoryController;

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
  late bool _isLoggedIn;
  final GlobalKey dropdownKey = GlobalKey();
  XFile? _pickedCoverXFile;
  final List<XFile?> _portfolioImages = List<XFile?>.filled(3, null);
  final ImagePicker _picker = ImagePicker();
  late FreelancerProvider freelancerProvider;
  final List<String> _customCategoryNames = [];
  bool _isSubmittingApplication = false;

  @override
  void initState() {
    super.initState();
    final ProfileProvider profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    setProfileFormField(profileProvider, authProvider);
  }

  void setProfileFormField(
      ProfileProvider profileProvider, AuthProvider authProvider) {
    _isLoggedIn = authProvider.isLoggedIn();
    _firstNameFocus = FocusNode();
    _aboutMe = FocusNode();
    _phoneNumberFocus = FocusNode();

    _firstNameController = TextEditingController();
    _aboutMeController = TextEditingController();
    _perhourController = TextEditingController();
    _perkmChargesController = TextEditingController();
    _perdayChargesController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _customCategoryController = TextEditingController();
    freelancerProvider =
        Provider.of<FreelancerProvider>(context, listen: false);

    if (_isLoggedIn) {
      profileProvider.getUserInfo(true).then((_) {
        UserInfoModel? userInfoModel = profileProvider.userInfoModel;
        if (userInfoModel != null) {
          _firstNameController!.text = userInfoModel.name ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _firstNameFocus?.dispose();
    _aboutMe?.dispose();
    _phoneNumberFocus?.dispose();
    _firstNameController?.dispose();
    _aboutMeController?.dispose();
    _perhourController?.dispose();
    _perdayChargesController?.dispose();
    _perkmChargesController?.dispose();
    _phoneNumberController?.dispose();
    _customCategoryController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        appBar: (!_isLoggedIn
            ? CustomAppBarWidget(
                context: context,
                title: getTranslated('apply_freelancer', context)!,
                centerTitle: true,
              )
            : null) as PreferredSizeWidget?,
        body: _isLoggedIn
            ? Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  return profileProvider.userInfoModel != null
                      ? Container(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.8),
                          child: Column(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(top: 10),
                                  width: double.infinity,
                                  height: Dimensions.paddingSizeExtraLarge),

                              /// TOP HEADER
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: Dimensions.paddingSizeSmall),
                                    child: IconButton(
                                      onPressed: () => context.pop(),
                                      icon: const Icon(Icons.arrow_back_ios),
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    getTranslated('apply_freelancer', context)!,
                                    style: rubikSemiBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeOverLarge),
                                ],
                              ),

                              /// TOP BANNER IMAGE
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault),
                                child: Stack(
                                  children: [
                                    /// ----------- COVER IMAGE ---------------
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _pickedCoverXFile != null
                                          ? Image.file(
                                              File(_pickedCoverXFile!
                                                  .path), // convert XFile → File
                                              width: double.infinity,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            )
                                          : CustomImageWidget(
                                              placeholder:
                                                  Images.placeholderUser,
                                              width: double.infinity,
                                              height: 150,
                                              fit: BoxFit.cover,
                                              image:
                                                  '${profileProvider.userInfoModel!.image}',
                                            ),
                                    ),

                                    /// ----------- PICK BUTTON (BOTTOM RIGHT) ---------------
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: _pickCoverImage,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// EXPANDED AREA BELOW
                              Expanded(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    /// WHITE FULL BACKGROUND (BOTTOM AREA)
                                    Positioned.fill(
                                      top: -50,
                                      child: CustomPaint(
                                        painter:
                                            ProfileCustomPainterWidget(context),
                                      ),
                                    ),

                                    /// PROFILE CIRCLE OVERLAPPING
                                    Positioned(
                                      top: -20,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: ColorResources.borderColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color:
                                                    ColorResources.priamrycolor,
                                                width: 1.5),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: CustomImageWidget(
                                              placeholder:
                                                  Images.placeholderUser,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              image:
                                                  '${profileProvider.userInfoModel!.image}',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// SCROLL FORM AREA
                                    Positioned.fill(
                                      top:
                                          50, // adjust spacing under profile circle
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: SingleChildScrollView(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeDefault),
                                              child: Form(
                                                key: profileFormKey,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 20),

                                                    Text('Portfolio Images',
                                                        style: rubikSemiBold),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: List.generate(
                                                        _portfolioImages.length,
                                                        (index) => Expanded(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              right: index ==
                                                                      _portfolioImages
                                                                              .length -
                                                                          1
                                                                  ? 0
                                                                  : 10,
                                                            ),
                                                            child:
                                                                _portfolioImagePicker(
                                                                    index),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),

                                                    ProfileTextFieldWidget(
                                                      isShowBorder: true,
                                                      controller:
                                                          _firstNameController,
                                                      focusNode:
                                                          _firstNameFocus,
                                                      inputType:
                                                          TextInputType.name,
                                                      capitalization:
                                                          TextCapitalization
                                                              .words,
                                                      level: getTranslated(
                                                          'first_name',
                                                          context)!,
                                                      isShowPrefixIcon: true,
                                                      isEnabled: false,
                                                      prefixIconUrl:
                                                          Images.profileIconSvg,
                                                    ),

                                                    SizedBox(height: 20),

                                                    /// CATEGORY DROPDOWN
                                                    Text(
                                                      getTranslated(
                                                          'freelancer_category',
                                                          context)!,
                                                      style: rubikSemiBold,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Consumer<
                                                        FreelancerProvider>(
                                                      builder: (context,
                                                          freelancerProvider,
                                                          child) {
                                                        final String
                                                            selectedText =
                                                            _buildSelectedCategoryText(
                                                          categoryProvider,
                                                          freelancerProvider,
                                                        );

                                                        final List<Widget>
                                                            chips =
                                                            freelancerProvider
                                                                .selectedCategoryIDs
                                                                .map((id) {
                                                          final matches =
                                                              (categoryProvider
                                                                          .categoryList ??
                                                                      [])
                                                                  .where((c) =>
                                                                      c.id ==
                                                                      id)
                                                                  .toList();
                                                          if (matches.isEmpty) {
                                                            return const SizedBox
                                                                .shrink();
                                                          }

                                                          final cat =
                                                              matches.first;
                                                          return Chip(
                                                            label: Text(
                                                                cat.name ?? ''),
                                                            onDeleted: () {
                                                              freelancerProvider
                                                                  .setCategoryID(
                                                                      categoryID:
                                                                          id);
                                                            },
                                                          );
                                                        }).toList();

                                                        for (final String name
                                                            in _customCategoryNames) {
                                                          if (name
                                                              .trim()
                                                              .isEmpty) {
                                                            continue;
                                                          }

                                                          chips.add(
                                                            Chip(
                                                              label: Text(
                                                                  name.trim()),
                                                              backgroundColor: Theme
                                                                      .of(
                                                                          context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.12),
                                                              avatar:
                                                                  const Icon(
                                                                Icons.star,
                                                                size: 18,
                                                              ),
                                                              onDeleted: () {
                                                                setState(() {
                                                                  _customCategoryNames
                                                                      .remove(
                                                                          name);
                                                                });
                                                              },
                                                            ),
                                                          );
                                                        }

                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  _openCategorySelector(
                                                                categoryProvider,
                                                                freelancerProvider,
                                                              ),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 14,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault),
                                                                  border: Border
                                                                      .all(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor,
                                                                  ),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        selectedText,
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            rubikRegular,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Icon(
                                                                      Icons
                                                                          .arrow_drop_down,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .hintColor,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 12),
                                                            Wrap(
                                                              spacing: 8,
                                                              runSpacing: 8,
                                                              children: chips,
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                    SizedBox(height: 20),

                                                    /// PHONE
                                                    ProfileTextFieldWidget(
                                                      isShowBorder: true,
                                                      controller:
                                                          _phoneNumberController,
                                                      focusNode:
                                                          _phoneNumberFocus,
                                                      inputType:
                                                          TextInputType.phone,
                                                      level: getTranslated(
                                                          'whatsapp', context)!,
                                                      isShowPrefixIcon: true,
                                                      prefixIconUrl:
                                                          Images.whatsapp,
                                                    ),

                                                    SizedBox(height: 20),

                                                    ///Price

                                                    Text('Price per day ',
                                                        style: rubikSemiBold),

                                                    CustomTextFieldWidget(
                                                      controller:
                                                          _perdayChargesController,
                                                      maxLines: 1,
                                                      inputType:
                                                          TextInputType.number,
                                                      hintText:
                                                          'Enter your price',
                                                      isShowBorder: true,
                                                    ),

                                                    SizedBox(height: 30),

                                                    //Per km charges

                                                    Text('Per Km charges',
                                                        style: rubikSemiBold),

                                                    CustomTextFieldWidget(
                                                      controller:
                                                          _perkmChargesController,
                                                      maxLines: 1,
                                                      inputType:
                                                          TextInputType.number,
                                                      hintText:
                                                          'Per Km charges',
                                                      isShowBorder: true,
                                                    ),

                                                    SizedBox(height: 30),
                                                    Text('Per hour (Rs)',
                                                        style: rubikSemiBold),

                                                    CustomTextFieldWidget(
                                                      controller:
                                                          _perhourController,
                                                      maxLines: 1,
                                                      inputType:
                                                          TextInputType.number,
                                                      hintText:
                                                          'Per hour charges',
                                                      isShowBorder: true,
                                                    ),

                                                    SizedBox(height: 30),

                                                    /// ABOUT ME
                                                    Text(
                                                        getTranslated(
                                                            'about_me',
                                                            context)!,
                                                        style: rubikSemiBold),
                                                    CustomTextFieldWidget(
                                                      controller:
                                                          _aboutMeController,
                                                      maxLines: 5,
                                                      isShowBorder: true,
                                                    ),

                                                    SizedBox(height: 30),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          /// BUTTON
                                          Padding(
                                            padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeSmall,
                                            ),
                                            child: Consumer2<FreelancerProvider,
                                                FreelancerPortfolioProvider>(
                                              builder: (context,
                                                  freelancerProvider,
                                                  portfolioProvider,
                                                  child) {
                                                return CustomButtonWidget(
                                                  width: double.infinity,
                                                  btnTxt: getTranslated(
                                                      'apply', context),
                                                  isLoading:
                                                      _isSubmittingApplication ||
                                                          freelancerProvider
                                                              .isLoading ||
                                                          portfolioProvider
                                                              .isLoading,
                                                  onTap: _submitApplication,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      : const ProfileShimmerWidget();
                },
              )
            : const NotLoggedInWidget(),
      ),
    );
  }

  Widget _portfolioImagePicker(int index) {
    final XFile? image = _portfolioImages[index];

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _pickPortfolioImage(index),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorResources.borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null)
                Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                )
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Image ${index + 1}',
                      style: rubikRegular.copyWith(
                        color: ColorResources.getHintColor(context),
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              if (image != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _portfolioImages[index] = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPortfolioImage(int index) async {
    final Color primaryColor = Theme.of(context).primaryColor;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 35,
        maxHeight: 900,
        maxWidth: 900,
      );

      if (pickedFile == null) {
        return;
      }

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 45,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Portfolio Image',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
            cropStyle: CropStyle.rectangle,
            aspectRatioPresets: const [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Portfolio Image',
            aspectRatioLockEnabled: false,
            aspectRatioPickerButtonHidden: false,
            resetAspectRatioEnabled: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (croppedFile == null) {
        return;
      }

      // compress the cropped image to be under ~1MB
      final File original = File(croppedFile.path);
      final compressed = await ImageUtils.compressFile(original);

      setState(() {
        _portfolioImages[index] = XFile(compressed.path);
      });
    } catch (e) {
      debugPrint('Portfolio Image Process Error: $e');
    }
  }

  Future<void> _submitApplication() async {
    if (_isSubmittingApplication) {
      debugPrint('Application submission already in progress');
      return;
    }

    final List<XFile> selectedPortfolioImages =
        _portfolioImages.whereType<XFile>().toList();

    if (selectedPortfolioImages.length != _portfolioImages.length) {
      showCustomSnackBarHelper('Please upload 3 portfolio images',
          status: SnackBarStatus.alert);
      return;
    }

    final String? customCategoryName = _customCategoryNames.isNotEmpty
        ? _customCategoryNames.join(', ')
        : null;

    if (freelancerProvider.selectedCategoryIDs.isEmpty &&
        customCategoryName == null) {
      showCustomSnackBarHelper('Please select at least one category',
          status: SnackBarStatus.alert);
      return;
    }

    if (!_validateFields(context)) {
      return;
    }

    final ApplyFreelancerModel model = ApplyFreelancerModel(
      about: _aboutMeController?.text.trim() ?? '',
      price: _perdayChargesController?.text.trim() ?? '',
      per_side: _perkmChargesController?.text.trim() ?? '',
      per_hour: _perhourController?.text.trim() ?? '',
      cover_picture: _pickedCoverXFile?.path ?? '',
      whatsapp_number: _phoneNumberController?.text.trim() ?? '',
      category_id: freelancerProvider.selectedCategoryIDs.isNotEmpty
          ? freelancerProvider.selectedCategoryIDs
          : null,
      other_category: customCategoryName,
    );

    // debugPrint('===== MODEL DATA =====');
    // debugPrint('About: ${model.about}');
    // debugPrint('Price Per Day: ${model.price}');
    // debugPrint('Per Side: ${model.per_side}');
    // debugPrint('Per Hour: ${model.per_hour}');
    // debugPrint('Cover Picture: ${model.cover_picture}');
    // debugPrint('Whatsapp Number: ${model.whatsapp_number}');
    // debugPrint('Category ID: ${model.category_id}');
    // debugPrint('Other Category: ${model.other_category}');

    setState(() {
      _isSubmittingApplication = true;
    });

    try {
      final FreelancerPortfolioProvider portfolioProvider =
          Provider.of<FreelancerPortfolioProvider>(
        context,
        listen: false,
      );

      final String token =
          Provider.of<AuthProvider>(context, listen: false).getUserToken();

      for (final XFile image in selectedPortfolioImages) {
        final responseModel = await portfolioProvider.freelancerPortfolioAdd(
          File(image.path),
          token,
        );

        debugPrint('Response message: ${responseModel.message}');

        if (!responseModel.isSuccess) {
          if (mounted) {
            setState(() {
              _isSubmittingApplication = false;
            });
          }

          showCustomSnackBarHelper(responseModel.message,
              status: SnackBarStatus.error);
          return;
        }
      }

      await freelancerProvider.applyFreelancer(model, _callback);
    } catch (e, stackTrace) {
      debugPrint('===== ERROR IN SUBMIT APPLICATION =====');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      showCustomSnackBarHelper('Something went wrong',
          status: SnackBarStatus.error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingApplication = false;
        });
      }
    }
  }

  void _callback(bool isSuccess, String message) async {
    if (isSuccess) {
      final FreelancerProvider freelancerProvider =
          Provider.of<FreelancerProvider>(context, listen: false);
      final ProfileProvider profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      freelancerProvider.resetCategoryID();
      if (mounted) {
        setState(() {
          _customCategoryNames.clear();
        });
      }
      profileProvider.getUserInfo(true);
      RouterHelper.getOrderSuccessScreen('success', message);
    } else {
      if (mounted) {
        setState(() {
          _isSubmittingApplication = false;
        });
      }
      showCustomSnackBarHelper(message);
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final Color primaryColor = Theme.of(context).primaryColor;
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 35,
        maxHeight: 900,
        maxWidth: 1200,
      );

      if (pickedFile != null) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 45,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Cover Image',
              toolbarColor: primaryColor,
              toolbarWidgetColor: Colors.white,
              //    statusBarIconBrightness: Brightness.light,
              lockAspectRatio: false,

              cropStyle: CropStyle.rectangle,
              aspectRatioPresets: const [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio16x9,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.square,
              ],
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: 'Crop Cover Image',
              aspectRatioLockEnabled: false,
              aspectRatioPickerButtonHidden: true,
              resetAspectRatioEnabled: true,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio16x9,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.square,
              ],
            ),
          ],
        );

        if (croppedFile == null) return;

        final File original = File(croppedFile.path);
        final compressed = await ImageUtils.compressFile(original);

        setState(() {
          _pickedCoverXFile = XFile(compressed.path);
        });
      }
    } catch (e) {
      debugPrint('Cover Image Process Error: $e');
    }
  }

  Future<void> _openCategorySelector(CategoryProvider categoryProvider,
      FreelancerProvider freelancerProvider) async {
    final List<int> tempSelectedIds =
        List<int>.from(freelancerProvider.selectedCategoryIDs);
    final List<String> tempCustomCategoryNames =
        List<String>.from(_customCategoryNames);

    _customCategoryController?.clear();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final categories = categoryProvider.categoryList ?? [];

            void addCustomCategory() {
              final String trimmed =
                  _customCategoryController?.text.trim() ?? '';
              if (trimmed.isEmpty) {
                showCustomSnackBarHelper(
                  'Please enter category name',
                  status: SnackBarStatus.alert,
                );
                return;
              }

              setModalState(() {
                if (!tempCustomCategoryNames.contains(trimmed)) {
                  tempCustomCategoryNames.add(trimmed);
                }
                _customCategoryController?.clear();
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select Categories',
                              style: rubikSemiBold.copyWith(fontSize: 18),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (categories.isEmpty)
                        Text(
                          'No categories available right now.',
                          style: rubikRegular.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categories.map((cat) {
                            final bool isSelected =
                                tempSelectedIds.contains(cat.id);
                            return ChoiceChip(
                              selectedColor: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.12),
                              label: Text(cat.name ?? ''),
                              selected: isSelected,
                              onSelected: (_) {
                                setModalState(() {
                                  if (cat.id == null) {
                                    return;
                                  }
                                  if (isSelected) {
                                    tempSelectedIds.remove(cat.id);
                                  } else {
                                    tempSelectedIds.add(cat.id!);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Add new category',
                        style: rubikSemiBold.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFieldWidget(
                              controller: _customCategoryController,
                              maxLines: 1,
                              hintText: 'Enter new category',
                              isShowBorder: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CustomButtonWidget(
                            btnTxt: 'Add',
                            onTap: addCustomCategory,
                            width: 92,
                            height: 46,
                          ),
                        ],
                      ),
                      if (tempCustomCategoryNames.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tempCustomCategoryNames.map((name) {
                            return Chip(
                              label: Text(name),
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.12),
                              avatar: const Icon(Icons.star, size: 18),
                              onDeleted: () {
                                setModalState(() {
                                  tempCustomCategoryNames.remove(name);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          CustomButtonWidget(
                            btnTxt: 'Done',
                            onTap: () {
                              final String? customName =
                                  tempCustomCategoryNames.isNotEmpty
                                      ? tempCustomCategoryNames.join(', ')
                                      : null;

                              if (tempSelectedIds.isEmpty &&
                                  customName == null) {
                                showCustomSnackBarHelper(
                                  'Please select at least one category',
                                  status: SnackBarStatus.alert,
                                );
                                return;
                              }

                              Navigator.of(sheetContext).pop(<String, dynamic>{
                                'selectedCategoryIds': tempSelectedIds,
                                'customCategoryNames': tempCustomCategoryNames,
                              });
                            },
                            width: 92,
                            height: 46,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    final List<int> selectedCategoryIds =
        List<int>.from(result['selectedCategoryIds'] as List<dynamic>? ?? []);
    final List<String> customCategoryNames = List<String>.from(
        result['customCategoryNames'] as List<dynamic>? ?? []);

    if (!mounted) {
      return;
    }

    freelancerProvider.setCategoryIDs(selectedCategoryIds);
    setState(() {
      _customCategoryNames
        ..clear()
        ..addAll(customCategoryNames);
    });
  }

  String _buildSelectedCategoryText(CategoryProvider categoryProvider,
      FreelancerProvider freelancerProvider) {
    final List<String> selectedNames = [];
    final categories = categoryProvider.categoryList ?? [];

    for (final int id in freelancerProvider.selectedCategoryIDs) {
      final matches =
          categories.where((category) => category.id == id).toList();
      if (matches.isNotEmpty &&
          (matches.first.name?.trim().isNotEmpty ?? false)) {
        selectedNames.add(matches.first.name!.trim());
      }
    }

    for (final String name in _customCategoryNames) {
      if (name.trim().isNotEmpty) {
        selectedNames.add(name.trim());
      }
    }

    return selectedNames.isEmpty ? 'Select category' : selectedNames.join(', ');
  }

  bool _validateFields(BuildContext context) {
    // Keep all fields optional. Only validate numeric inputs if user entered values.
    final sideVisitText = _perdayChargesController?.text.trim() ?? '';
    if (sideVisitText.isNotEmpty && double.tryParse(sideVisitText) == null) {
      showCustomSnackBarHelper('Please enter a valid Per Day charge',
          status: SnackBarStatus.alert);
      return false;
    }

    final perKmText = _perkmChargesController?.text.trim() ?? '';
    if (perKmText.isNotEmpty && double.tryParse(perKmText) == null) {
      showCustomSnackBarHelper('Please enter a valid Per Km charge',
          status: SnackBarStatus.alert);
      return false;
    }

    final perHourText = _perhourController?.text.trim() ?? '';
    if (perHourText.isNotEmpty && double.tryParse(perHourText) == null) {
      showCustomSnackBarHelper('Please enter a valid Per Hour charge',
          status: SnackBarStatus.alert);
      return false;
    }

    return true;
  }
}
