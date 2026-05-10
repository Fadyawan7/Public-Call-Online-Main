import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
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
  static const String _newCategoryValue = 'new_category';

  FocusNode? _firstNameFocus;
  FocusNode? _aboutMe;
  FocusNode? _phoneNumberFocus;

  TextEditingController? _firstNameController;
  TextEditingController? _aboutMeController;
  TextEditingController? _perhourController;
  TextEditingController? _perdayChargesController;
  TextEditingController? _perkmChargesController;
  TextEditingController? _newCategoryController;
  TextEditingController? _phoneNumberController;

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
  late bool _isLoggedIn;
  final GlobalKey dropdownKey = GlobalKey();
  XFile? _pickedCoverXFile;
  final List<XFile?> _portfolioImages = List<XFile?>.filled(3, null);
  final ImagePicker _picker = ImagePicker();
  late FreelancerProvider freelancerProvider;
  String? _selectedCategoryValue;
  String? _customCategoryName;
  bool _showNewCategoryField = false;
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
    _newCategoryController = TextEditingController();
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
  void dispose() {
    _firstNameFocus?.dispose();
    _aboutMe?.dispose();
    _phoneNumberFocus?.dispose();
    _firstNameController?.dispose();
    _aboutMeController?.dispose();
    _perhourController?.dispose();
    _perdayChargesController?.dispose();
    _perkmChargesController?.dispose();
    _newCategoryController?.dispose();
    _phoneNumberController?.dispose();
    super.dispose();
  }

  void _showCustomCategoryInput() {
    setState(() {
      _selectedCategoryValue = _newCategoryValue;
      _showNewCategoryField = true;
    });
    freelancerProvider.resetCategoryID();
  }

  void _addCustomCategory() {
    final String categoryName = _newCategoryController?.text.trim() ?? '';
    if (categoryName.isEmpty) {
      showCustomSnackBarHelper('Please enter category name');
      return;
    }

    setState(() {
      _customCategoryName = categoryName;
      _selectedCategoryValue = _newCategoryValue;
      _showNewCategoryField = false;
    });

    FocusScope.of(context).unfocus();
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.8),
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
                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback(
                                                                (_) {
                                                          if (_selectedCategoryValue == null &&
                                                              freelancerProvider
                                                                      .selectedCategoryID ==
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
                                                            if (mounted) {
                                                              setState(() {
                                                                _selectedCategoryValue =
                                                                    categoryProvider
                                                                        .categoryList!
                                                                        .first
                                                                        .id!
                                                                        .toString();
                                                              });
                                                            }
                                                          }
                                                        });

                                                        return Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                child:
                                                                    DropdownButton2<
                                                                        String>(
                                                                  isExpanded:
                                                                      true,
                                                                  items: [
                                                                    ...categoryProvider
                                                                        .categoryList!
                                                                        .map(
                                                                      (cat) =>
                                                                          DropdownMenuItem<
                                                                              String>(
                                                                        value: cat
                                                                            .id
                                                                            .toString(),
                                                                        child:
                                                                            Text(
                                                                          cat.name ??
                                                                              "",
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          _newCategoryValue,
                                                                      child: Text(
                                                                          'Add Category'),
                                                                    ),
                                                                  ],
                                                                  value:
                                                                      _selectedCategoryValue,
                                                                  selectedItemBuilder:
                                                                      (context) {
                                                                    return [
                                                                      ...categoryProvider
                                                                          .categoryList!
                                                                          .map(
                                                                        (cat) =>
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Text(
                                                                            cat.name ??
                                                                                '',
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Text(
                                                                          _customCategoryName ??
                                                                              'Add Category',
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ];
                                                                  },
                                                                  onChanged:
                                                                      (value) {
                                                                    if (value ==
                                                                        null) {
                                                                      return;
                                                                    }

                                                                    if (value ==
                                                                        _newCategoryValue) {
                                                                      _showCustomCategoryInput();
                                                                      //     Navigator.of(context).pop();

                                                                      return;
                                                                    }

                                                                    setState(
                                                                        () {
                                                                      _selectedCategoryValue =
                                                                          value;
                                                                      _showNewCategoryField =
                                                                          false;
                                                                      _customCategoryName =
                                                                          null;
                                                                      _newCategoryController
                                                                          ?.clear();
                                                                    });
                                                                    freelancerProvider.setCategoryID(
                                                                        categoryID:
                                                                            int.parse(value));
                                                                  },
                                                                  buttonStyleData:
                                                                      ButtonStyleData(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              Theme.of(context).hintColor),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              Dimensions.radiusDefault),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                    if (_showNewCategoryField) ...[
                                                      const SizedBox(
                                                          height: 12),
                                                      CustomTextFieldWidget(
                                                        controller:
                                                            _newCategoryController,
                                                        maxLines: 1,
                                                        hintText:
                                                            'Enter new category',
                                                        isShowBorder: true,
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child:
                                                              CustomButtonWidget(
                                                            btnTxt: 'Add',
                                                            onTap:
                                                                _addCustomCategory,
                                                            width: 100,
                                                            height: 40,
                                                          )),
                                                    ],

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

    debugPrint('===== START SUBMIT APPLICATION =====');

    final List<XFile> selectedPortfolioImages =
        _portfolioImages.whereType<XFile>().toList();

    debugPrint('Selected portfolio images: ${selectedPortfolioImages.length}');
    debugPrint(
        'Total portfolio images list length: ${_portfolioImages.length}');

    if (selectedPortfolioImages.length != _portfolioImages.length) {
      debugPrint('Portfolio images validation failed');
      showCustomSnackBarHelper('Please upload 3 portfolio images');
      return;
    }

    final bool isCustomCategory = _selectedCategoryValue == _newCategoryValue;

    debugPrint('Is custom category: $isCustomCategory');
    debugPrint('Selected category value: $_selectedCategoryValue');
    debugPrint('New category value: $_newCategoryValue');

    if (isCustomCategory &&
        (_customCategoryName == null || _customCategoryName!.trim().isEmpty)) {
      debugPrint('Custom category validation failed');
      showCustomSnackBarHelper('Please add category first');
      return;
    }

    debugPrint('Running field validations');

    if (!_validateFields(context)) {
      debugPrint('Field validation failed');
      return;
    }

    debugPrint('All validations passed');

    final ApplyFreelancerModel model = ApplyFreelancerModel(
      about: _aboutMeController?.text.trim() ?? '',
      price: _perdayChargesController?.text.trim() ?? '',
      per_side: _perkmChargesController?.text.trim() ?? '',
      per_hour: _perhourController?.text.trim() ?? '',
      cover_picture: _pickedCoverXFile?.path ?? '',
      whatsapp_number: _phoneNumberController?.text.trim() ?? '',
      category_id:
          isCustomCategory ? null : freelancerProvider.selectedCategoryID,
      other_category: isCustomCategory ? _customCategoryName : null,
    );

    debugPrint('===== MODEL DATA =====');
    debugPrint('About: ${model.about}');
    debugPrint('Price Per Day: ${model.price}');
    debugPrint('Per Side: ${model.per_side}');
    debugPrint('Per Hour: ${model.per_hour}');
    debugPrint('Cover Picture: ${model.cover_picture}');
    debugPrint('Whatsapp Number: ${model.whatsapp_number}');
    debugPrint('Category ID: ${model.category_id}');
    debugPrint('Other Category: ${model.other_category}');

    setState(() {
      _isSubmittingApplication = true;
    });

    debugPrint('Application submitting state set to true');

    try {
      final FreelancerPortfolioProvider portfolioProvider =
          Provider.of<FreelancerPortfolioProvider>(
        context,
        listen: false,
      );

      final String token =
          Provider.of<AuthProvider>(context, listen: false).getUserToken();

      debugPrint('User token fetched');
      debugPrint('Uploading portfolio images');

      int imageIndex = 0;

      for (final XFile image in selectedPortfolioImages) {
        imageIndex++;

        debugPrint('Uploading image #$imageIndex');
        debugPrint('Image path: ${image.path}');

        final responseModel = await portfolioProvider.freelancerPortfolioAdd(
          File(image.path),
          token,
        );

        debugPrint(
            'Upload response for image #$imageIndex: ${responseModel.isSuccess}');
        debugPrint('Response message: ${responseModel.message}');

        if (!responseModel.isSuccess) {
          debugPrint('Portfolio upload failed');

          if (mounted) {
            setState(() {
              _isSubmittingApplication = false;
            });
          }

          showCustomSnackBarHelper(responseModel.message);
          return;
        }
      }

      debugPrint('All portfolio images uploaded successfully');
      debugPrint('Calling applyFreelancer API');

      await freelancerProvider.applyFreelancer(model, _callback);

      debugPrint('applyFreelancer API completed');
    } catch (e, stackTrace) {
      debugPrint('===== ERROR IN SUBMIT APPLICATION =====');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      showCustomSnackBarHelper('Something went wrong');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingApplication = false;
        });
      }

      debugPrint('Application submitting state reset');
      debugPrint('===== END SUBMIT APPLICATION =====');
    }
  }

  void _callback(bool isSuccess, String message) async {
    if (isSuccess) {
      final FreelancerProvider freelancerProvider =
          Provider.of<FreelancerProvider>(context, listen: false);
      final ProfileProvider profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      freelancerProvider.resetCategoryID();
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

  bool _validateFields(BuildContext context) {
    // Keep all fields optional. Only validate numeric inputs if user entered values.
    final sideVisitText = _perdayChargesController?.text.trim() ?? '';
    if (sideVisitText.isNotEmpty && double.tryParse(sideVisitText) == null) {
      showCustomSnackBarHelper('Please enter a valid Per Day charge');
      return false;
    }

    final perKmText = _perkmChargesController?.text.trim() ?? '';
    if (perKmText.isNotEmpty && double.tryParse(perKmText) == null) {
      showCustomSnackBarHelper('Please enter a valid Per Km charge');
      return false;
    }

    final perHourText = _perhourController?.text.trim() ?? '';
    if (perHourText.isNotEmpty && double.tryParse(perHourText) == null) {
      showCustomSnackBarHelper('Please enter a valid Per Hour charge');
      return false;
    }

    return true;
  }
}
