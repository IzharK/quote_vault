import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quote_vault/core/theme/app_colors.dart';
import 'package:quote_vault/core/widgets/background_gradient.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Mock state for now. In real implementation, this comes from SharedPreferences/LocalNotifications.
  bool _dailyQuoteEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111218);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: BackgroundGradient(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 24,
            left: 16,
            right: 16,
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: SwitchListTile(
                  value: _dailyQuoteEnabled,
                  activeColor: AppColors.primary,
                  title: Text(
                    "Daily Quote",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    "Get your daily dose of wisdom at 9:00 AM",
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                  onChanged: (val) {
                    setState(() => _dailyQuoteEnabled = val);
                    // TODO: Implement notification scheduling logic here later
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Notifications ${val ? 'Enabled' : 'Disabled'} (Mock)",
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_dailyQuoteEnabled)
                Text(
                  "More notification settings coming soon.",
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
