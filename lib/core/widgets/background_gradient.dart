import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quote_vault/core/theme/app_colors.dart';

class BackgroundGradient extends StatelessWidget {
  final Widget? child;

  const BackgroundGradient({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? AppColors.pastelGradientDark
        : AppColors.pastelGradientLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // Android: Dark icons for light mode (light background)
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        // iOS: Light background for light mode
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: child,
      ),
    );
  }
}
