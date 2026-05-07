import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ColorResources {
  static Color getSearchBg(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF1B2240)
        : const Color(0xFFF7F9FF);
  }

  static Color getBackgroundColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF121832)
        : const Color(0xFFF7F9FF);
  }

  static Color getHintColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFFA7B0C0)
        : const Color(0xFF8B96A5);
  }

  static Color getGreyBunkerColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFFE8ECFF)
        : const Color(0xFF1C255A);
  }

  static Color getCartTitleColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF9FB2FF)
        : const Color(0xFF1C255A);
  }

  static Color getProfileMenuHeaderColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? footerColor.withOpacity(0.5)
        : footerColor.withOpacity(0.2);
  }

  static Color getFooterColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF1B2240)
        : const Color(0xFFE8EEFF);
  }

  static Color getSecondaryColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF9FB2FF)
        : const Color(0xFF9FB2FF);
  }

  static Color getTertiaryColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF171D3B)
        : const Color(0xFFF1F4FF);
  }

  static const Color colorNero = Color(0xFF1F1F1F);
  static const Color searchBg = Color(0xFFF7F9FF);
  static const Color borderColor = Color(0xFFDDE3F0);
  static const Color footerColor = Color(0xFFE8EEFF);
  static const Color cardShadowColor = Color(0x1A1B2A4D);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color onBoardingBgColor = Color(0xFFF1F4FF);
  static const Color homePageSectionTitleColor = Color(0xFF1C255A);
  static const Color splashBackgroundColor = Color(0xFF5C6CFF);

  static const Map<String, Color> buttonBackgroundColorMap = {
    'pending': Color(0xFFE8EEFF),
    'confirmed': Color(0xFFE1E9FF),
    'cancelled': Color(0xFFEFF2FF),
    'rejected': Color(0xFFEFF2FF),
    'completed': Color(0xFFE1E9FF),
  };

  static const Map<String, Color> buttonTextColorMap = {
    'pending': Color(0xFF5C6CFF),
    'confirmed': Color(0xFF4A5AF2),
    'cancelled': Color(0xFF4A5AF2),
    'rejected': Color(0xFF4A5AF2),
    'completed': Color(0xFF4A5AF2),
  };
}
