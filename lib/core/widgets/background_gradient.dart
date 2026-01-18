import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundGradient extends StatelessWidget {
  final Widget? child;

  const BackgroundGradient({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    // specific hardcoded surface for light mode to match design if needed,
    // but better to use theme surface so it adapts to seed?
    // Start with a clean logic.

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              surface,
              Color.lerp(surface, primary, 0.35)!, // Increased intensity
            ]
          : [
              const Color(0xFFF2F2F5), // Slightly grayish white start
              Color.lerp(Colors.white, primary, 0.25)!, // More saturated tint
            ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: child,
      ),
    );
  }
}
