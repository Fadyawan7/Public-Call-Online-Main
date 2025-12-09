import 'dart:io';
import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/category_model_response.dart';
import 'package:flutter_restaurant/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_button_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_restaurant/common/widgets/not_logged_in_widget.dart';
import 'package:flutter_restaurant/features/apply_freelancer/domain/models/apply_freelancer_model.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/category/domain/category_model.dart';
import 'package:flutter_restaurant/features/category/providers/category_provider.dart';
import 'package:flutter_restaurant/features/freelancer/providers/freelancer_provider.dart';
import 'package:flutter_restaurant/features/profile/domain/models/userinfo_model.dart';
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/features/profile/widgets/profile_custom_painter_widget.dart';
import 'package:flutter_restaurant/features/profile/widgets/profile_shimmer_widget.dart';
import 'package:flutter_restaurant/features/profile/widgets/profile_textfield_widget.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
  late bool _isLoggedIn;
  final GlobalKey dropdownKey = GlobalKey();
  XFile? _pickedCoverXFile;
  final ImagePicker _picker = ImagePicker();
  late FreelancerProvider freelancerProvider;
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
                          color: Theme.of(context).primaryColor,
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
                                                color: Colors.white54,
                                                width: 3),
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
                                          100, // adjust spacing under profile circle
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
                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback(
                                                                (_) {
                                                          if (freelancerProvider.selectedCategoryID ==
                                                                  -1 &&
                                                              categoryProvider
                                                                      .categoryList !=
                                                                  null &&
                                                              categoryProvider
                                                                  .categoryList!
                                                                  .isNotEmpty) {
                                                            freelancerProvider
                                                                .setCategoryID(
                                                                    categoryID: categoryProvider
                                                                        .categoryList!
                                                                        .first
                                                                        .id!);
                                                          }
                                                        });

                                                        return DropdownButtonHideUnderline(
                                                          child:
                                                              DropdownButton2(
                                                            isExpanded: true,
                                                            items: categoryProvider
                                                                .categoryList!
                                                                .map((cat) =>
                                                                    DropdownMenuItem(
                                                                      value: cat
                                                                          .id
                                                                          .toString(),
                                                                      child: Text(
                                                                          cat.name ??
                                                                              ""),
                                                                    ))
                                                                .toList(),
                                                            value: freelancerProvider
                                                                        .selectedCategoryID ==
                                                                    -1
                                                                ? null
                                                                : freelancerProvider
                                                                    .selectedCategoryID
                                                                    .toString(),
                                                            onChanged: (value) {
                                                              freelancerProvider
                                                                  .setCategoryID(
                                                                      categoryID:
                                                                          int.parse(
                                                                              value!));
                                                            },
                                                            buttonStyleData:
                                                                ButtonStyleData(
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusDefault),
                                                              ),
                                                            ),
                                                          ),
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
                                                    Text('Per per hour (Rs)',
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
                                            child: CustomButtonWidget(
                                              btnTxt: getTranslated(
                                                  'apply', context),
                                              isLoading:
                                                  profileProvider.isLoading,
                                              onTap: () {
                                                if (!_validateFields(context)) {
                                                  return;
                                                }

                                                // All validations passed
                                                ApplyFreelancerModel model =
                                                    ApplyFreelancerModel(
                                                  about: _aboutMeController
                                                          ?.text
                                                          .trim() ??
                                                      '',
                                                  price: _perdayChargesController
                                                          ?.text
                                                          .trim() ??
                                                      '',
                                                  per_side:
                                                      _perkmChargesController
                                                              ?.text
                                                              .trim() ??
                                                          '',
                                                  per_hour:
                                                      _perhourController
                                                              ?.text
                                                              .trim() ??
                                                          '',
                                                  cover_picture:
                                                      _pickedCoverXFile?.path ??
                                                          '',
                                                  whatsapp_number:
                                                      _phoneNumberController
                                                              ?.text
                                                              .trim() ??
                                                          '',
                                                  category_id: freelancerProvider
                                                          .selectedCategoryID ??
                                                      0,
                                                );

                                                freelancerProvider
                                                    .applyFreelancer(
                                                        model, _callback);
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

  void _callback(bool isSuccess, String message) async {
    if (isSuccess) {
      Provider.of<FreelancerProvider>(context, listen: false).resetCategoryID();
      Provider.of<ProfileProvider>(context, listen: false).getUserInfo(true);
      RouterHelper.getOrderSuccessScreen('success', message);
    } else {
      showCustomSnackBarHelper(message);
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        // Optional: process the image (crop/resize) and save temp
        final bytes = await pickedFile.readAsBytes();
        final originalImage = img.decodeImage(bytes);

        if (originalImage != null) {
          final minDimension = min(originalImage.width, originalImage.height);
          final offsetX = (originalImage.width - minDimension) ~/ 2;
          final offsetY = (originalImage.height - minDimension) ~/ 2;

          final croppedImage = img.copyCrop(
            originalImage,
            x: offsetX,
            y: offsetY,
            width: minDimension,
            height: minDimension,
          );

          final resizedImage =
              img.copyResize(croppedImage, width: 500, height: 500);

          final tempDir = await getTemporaryDirectory();
          final processedFile = File(
              '${tempDir.path}/cover_${DateTime.now().millisecondsSinceEpoch}.png');
          await processedFile.writeAsBytes(img.encodePng(resizedImage));

          setState(() {
            _pickedCoverXFile = XFile(processedFile.path); // Keep as XFile
          });
        }
      }
    } catch (e) {
      debugPrint('Cover Image Process Error: $e');
    }
  }

  bool _validateFields(BuildContext context) {
    // Check cover image
    if (_pickedCoverXFile == null) {
      showCustomSnackBarHelper('Cover image is required');
      return false;
    }

    // Check phone number
    if (_phoneNumberController?.text.trim().isEmpty ?? true) {
      showCustomSnackBarHelper('WhatsApp number is required');
      return false;
    }

    // Check side visit charges field
    if (_perdayChargesController?.text.trim().isEmpty ?? true) {
      showCustomSnackBarHelper('Per Day charges are required');
      return false;
    }

    // Validate side visit charges is a valid number
    final sideVisitText = _perdayChargesController?.text.trim() ?? '';
    if (double.tryParse(sideVisitText) == null) {
      showCustomSnackBarHelper('Please enter Per Day visit charges');
      return false;
    }

    // Check about me field
    if (_aboutMeController?.text.trim().isEmpty ?? true) {
      showCustomSnackBarHelper('About me is required');
      return false;
    }

    // Check Km field
    if (_perkmChargesController?.text.trim().isEmpty ?? true) {
      showCustomSnackBarHelper('Price Km is required');
      return false;
    }

    // Validate Km is a valid number
    final priceText = _perkmChargesController?.text.trim() ?? '';
    if (double.tryParse(priceText) == null) {
      showCustomSnackBarHelper('Please enter a valid price');
      return false;
    }
    // Check category is selected
    if (freelancerProvider.selectedCategoryID == null ||
        freelancerProvider.selectedCategoryID == 0) {
      showCustomSnackBarHelper('Please select a category');
      return false;
    }

    return true;
  }
}
