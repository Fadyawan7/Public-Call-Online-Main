
import 'package:flutter_restaurant/features/profile/providers/profile_provider.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:provider/provider.dart';

class UserTypeHelper {
  static bool isFreelancer() {
    final ProfileProvider profileProvider =
        Provider.of<ProfileProvider>(Get.context!, listen: false);

    // ⚡ Don't force null check
    final userInfo = profileProvider.userInfoModel;

    if (userInfo == null) {
      // data not loaded yet, return false or default
      return false;
    }

    String? userType = userInfo.userType;

    return userType == 'freelancer';
  }
}
