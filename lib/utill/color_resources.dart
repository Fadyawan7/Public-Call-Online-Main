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
        ? footerColor.withValues(alpha: 0.5)
        : footerColor.withValues(alpha: 0.2);
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
  static final Color priamrycolor = Color(0xFF5C6CFF);

  static const Color searchBg = Color(0xFFF7F9FF);
  static const Color borderColor = Color(0xFFDDE3F0);
  static const Color footerColor = Color(0xFFE8EEFF);
  static const Color cardShadowColor = Color(0x1A1B2A4D);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color onBoardingBgColor = Color(0xFFF1F4FF);
  static const Color homePageSectionTitleColor = Color(0xFF1C255A);
  static const Color splashBackgroundColor = Color(0xFF5C6CFF);
  static const Color statusApproved = Color(0xFF16A34A);
  static const Color statusApprovedBg = Color(0xFFE8F7EE);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusPendingBg = Color(0xFFFFF7E6);
  static const Color statusRejected = Color(0xFFDC2626);
  static const Color statusRejectedBg = Color(0xFFFFEAEA);

  static const Map<String, Color> buttonBackgroundColorMap = {
    'pending': statusPendingBg,
    'needed_more_data': statusPendingBg,
    'no-request': statusApprovedBg,
    'approved': statusApprovedBg,
    'confirmed': statusApprovedBg,
    'completed': statusApprovedBg,
    'cancelled': statusRejectedBg,
    'canceled': statusRejectedBg,
    'rejected': statusRejectedBg,
    'failed': statusRejectedBg,
  };

  static const Map<String, Color> buttonTextColorMap = {
    'pending': statusPending,
    'needed_more_data': statusPending,
    'no-request': statusApproved,
    'approved': statusApproved,
    'confirmed': statusApproved,
    'completed': statusApproved,
    'cancelled': statusRejected,
    'canceled': statusRejected,
    'rejected': statusRejected,
    'failed': statusRejected,
  };

  static Color getStatusTextColor(String? status, {Color? fallback}) {
    return buttonTextColorMap[status?.toLowerCase()] ??
        fallback ??
        statusPending;
  }

  static Color getStatusBackgroundColor(String? status, {Color? fallback}) {
    return buttonBackgroundColorMap[status?.toLowerCase()] ??
        fallback ??
        statusPendingBg;
  }
}
