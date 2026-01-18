import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/core/routes/route_names.dart';
import 'package:quote_vault/core/theme/app_colors.dart';
import 'package:quote_vault/core/widgets/background_gradient.dart';
import 'package:quote_vault/features/auth/presentation/providers/auth_provider.dart';
import 'package:quote_vault/features/profile/presentation/providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      context.read<ProfileProvider>().loadProfile(userId: userId);
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (mounted) {
        await context.read<ProfileProvider>().updateAvatar(File(image.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.avatarUpdated)),
          );
        }
      }
    }
  }

  Future<void> _signOut() async {
    await context.read<AuthProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    log('profile: ${profile?.fullName}');

    // Use specific colors from HTML or Theme
    // HTML uses #111218 (almost black) for text in light mode, White in dark.
    final headerTextColor = isDark ? Colors.white : const Color(0xFF111218);
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF616889);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            color: headerTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BackgroundGradient(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            bottom: 24,
            left: 16,
            right: 16,
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Avatar Section
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: isDark
                          ? Colors.grey[700]
                          : Colors.grey[200],
                      backgroundImage: profile?.avatarUrl != null
                          ? NetworkImage(profile!.avatarUrl!)
                          : null,
                      child: profile?.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 48,
                              color: isDark ? Colors.white : Colors.grey[400],
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                profile?.fullName ??
                    (profileProvider.status == ProfileStatus.loading
                        ? '...'
                        : 'User'),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: headerTextColor,
                ),
              ),

              const SizedBox(height: 32),

              // Settings Groups
              _buildSectionHeader('Account', subTextColor),
              _buildSettingsGroup(context, isDark, [
                _SettingsItem(
                  icon: Icons.person_outline,
                  label: 'Personal Information',
                  onTap: () => context.push(AppRouteNames.personalInfo),
                ),
                _SettingsItem(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  onTap: () => context.push(AppRouteNames.notifications),
                ),
              ]),

              const SizedBox(height: 24),

              _buildSectionHeader('Preferences', subTextColor),
              _buildSettingsGroup(context, isDark, [
                _SettingsItem(
                  icon: Icons.palette_outlined,
                  label: 'Appearance',
                  trailing: 'Light',
                ),
                _SettingsItem(
                  icon: Icons.language,
                  label: 'Language',
                  trailing: 'English',
                ),
              ]),

              const SizedBox(height: 48),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    'Log Out',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.red.withValues(alpha: .1), // red-100/900
                      ),
                    ),
                    shadowColor: Colors.black.withValues(alpha: .05),
                    elevation: 1,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Version 1.0.0',
                style: TextStyle(color: subTextColor, fontSize: 12),
              ),
              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2, // tracking-wider
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context,
    bool isDark,
    List<_SettingsItem> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: AppColors.primary, size: 20),
                ),
                title: Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF111218),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.trailing != null)
                      Text(
                        item.trailing!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    if (item.trailing != null) const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent:
                      72, // ml-16 (64px) + padding approx? HTML has ml-16 -> 4rem -> 64px.
                  color: isDark ? Colors.grey[700] : Colors.grey[100],
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  _SettingsItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });
}
