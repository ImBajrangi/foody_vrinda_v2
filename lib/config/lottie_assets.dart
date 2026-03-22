import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'app_theme.dart';

/// Lottie animation URLs and local assets
/// Provides a unified interface for loading both network and local animations
class LottieAssets {
  // Food & Delivery themed animations
  static const String cooking = 'https://assets4.lottiefiles.com/packages/lf20_tll0j4bb.json';
  static const String delivery = 'https://assets5.lottiefiles.com/packages/lf20_hy4txm7l.json';
  static const String foodDelivery = 'https://assets2.lottiefiles.com/packages/lf20_UJNc2t.json';

  // Success & Celebration
  static const String success = 'https://assets4.lottiefiles.com/packages/lf20_s2lryxtd.json';
  static const String celebration = 'https://assets1.lottiefiles.com/packages/lf20_touohxv0.json';
  static const String confetti = 'https://assets9.lottiefiles.com/packages/lf20_rovf9gzu.json';
  static const String checkmark = 'https://assets6.lottiefiles.com/packages/lf20_jbrw3hcz.json';
  static const String orderSuccess = 'https://assets3.lottiefiles.com/packages/lf20_wkaoioa4.json';

  // Loading & Progress
  static const String loading = 'https://assets9.lottiefiles.com/packages/lf20_x62chJ.json';
  static const String foodLoading = 'https://assets8.lottiefiles.com/packages/lf20_tll0j4bb.json';
  static const String dotsLoading = 'https://assets2.lottiefiles.com/packages/lf20_usmfx6bp.json';

  // Empty States
  static const String emptyCart = 'https://assets9.lottiefiles.com/packages/lf20_qh5z2fdq.json';
  static const String emptyBox = 'https://assets1.lottiefiles.com/packages/lf20_wnqlfojb.json';
  static const String noData = 'https://assets4.lottiefiles.com/packages/lf20_hl5n0bwb.json';
  static const String emptySearch = 'https://assets10.lottiefiles.com/packages/lf20_wnqlfojb.json';

  // Categories & Fun
  static const String pizzaSlices = 'https://assets3.lottiefiles.com/packages/lf20_OEskn908sL.json';
  static const String walkingBroccoli = 'https://assets3.lottiefiles.com/packages/lf20_C9edDzEy7H.json';
  static const String badCat = 'assets/animations/bad_cat.json';
  static const String deliveryScooter = 'assets/animations/delivery_scooter.json';
  static const String potato = 'https://assets3.lottiefiles.com/packages/lf20_pJLA1UHM2k.json';
  static const String growingTomatoes = 'https://assets3.lottiefiles.com/packages/lf20_GKQOcDtWhF.json';

  /// Helper to build a Lottie animation from either a URL or an asset path
  static Widget build(
    String source, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool repeat = true,
    bool animate = true,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    Widget defaultErrorBuilder(BuildContext context, Object error, StackTrace? stackTrace) => Icon(
          Icons.restaurant_menu,
          color: AppTheme.textSecondary.withValues(alpha: 0.2),
          size: width != null ? width * 0.5 : 24,
        );

    if (source.startsWith('http')) {
      return Lottie.network(
        source,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        animate: animate,
        errorBuilder: errorBuilder ?? defaultErrorBuilder,
      );
    } else {
      return Lottie.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        animate: animate,
        errorBuilder: errorBuilder ?? defaultErrorBuilder,
      );
    }
  }
}
