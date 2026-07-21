// profile_image_widget.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_image_widget.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/image_utils.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageWidget extends StatefulWidget {
  final String? imageUrl;
  final Function(File?) onImageSelected;

  const ProfileImageWidget({
    super.key,
    required this.imageUrl,
    required this.onImageSelected,
  });

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  File? _file;
  final ImagePicker _picker = ImagePicker();

  Future<void> _chooseImage() async {
    try {
      final Color primaryColor = Theme.of(context).primaryColor;
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 35,
        maxHeight: 900,
        maxWidth: 900,
      );

      if (pickedFile != null) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 45,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Profile Image',
              toolbarColor: primaryColor,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true,
              cropStyle: CropStyle.circle,
              aspectRatioPresets: const [
                CropAspectRatioPreset.square,
              ],
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: 'Crop Profile Image',
              cropStyle: CropStyle.circle,
              aspectRatioLockEnabled: true,
              aspectRatioPickerButtonHidden: false,
              resetAspectRatioEnabled: true,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
              ],
            ),
          ],
        );

        if (croppedFile == null) {
          return;
        }

        File original = File(croppedFile.path);
        final compressed =
            await ImageUtils.resizeAndCompressSquareFile(original);
        setState(() {
          _file = compressed;
        });
        widget.onImageSelected(_file);
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraLarge),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorResources.borderColor,
        border: Border.all(color: Colors.white54, width: 3),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        onTap: _chooseImage,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: _file != null
                  ? Image.file(_file!, width: 80, height: 80, fit: BoxFit.fill)
                  : CustomImageWidget(
                      placeholder: Images.placeholderUser,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      image: widget.imageUrl!,
                    ),
            ),
            Positioned(
              bottom: 15,
              right: -10,
              child: InkWell(
                onTap: _chooseImage,
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Icon(Icons.edit, size: 13, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
