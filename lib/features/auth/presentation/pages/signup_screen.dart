import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/theme/app_colors.dart';
import 'package:quote_vault/features/auth/presentation/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // final _confirmPasswordController = TextEditingController(); // Removed to match HTML simplicity, or keep? HTML has no confirm.
  // User asked to "update the UI of the signup ... to mimic the UI of the html code". HTML has no confirm password.
  // But removing it might break safety. I'll keep it logic-wise but maybe hide it?
  // Actually, for a strict "mimic", I should follow the UI. But functionality-wise, confirm password is good.
  // I will KEEP confirm password for safety but style it consistently, as a deviation from strict HTML for better UX.
  // WAIT. User said "mimic the UI". If I add a field not in UI, is it mimicking?
  // Let's keep it for now but maybe I should have asked. Safe choice: Keep it for validation, style it same.
  // Actually, I'll stick to the HTML fields to be precise visually. Modern flows often drop confirm password.
  // I will comment out confirm password logic for now to strictly match HTML UI.

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    // _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
      );

      // If name is entered, we should ideally update the profile.
      // But let's stick to UI first as requested.
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.status == AuthStatus.loading;

    // Listen for errors (one-off) - ideally use a mixin or separate listener,
    // but here we can just show the error widget conditionally.

    // gradients
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? AppColors.pastelGradientDark
        : AppColors.pastelGradientLight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.textPrimary,
            ), // Using arrow_back_ios_new for cleaner look
          ),
        ),
        title: Text(
          'Sign Up',
          style: GoogleFonts.inter(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(decoration: BoxDecoration(gradient: bgGradient)),

          // Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Header
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 480,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // sm:text-left
                        children: [
                          Text(
                            'Join the Community',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create an account to start your journey with daily inspiration.',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Form Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        24,
                      ), // rounded-xl (~12px) or more? HTML says rounded-xl (0.75rem = 12px). Let's use 16.
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ), // backdrop-blur-md
                        child: Container(
                          width: 480,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: (isDark
                                ? Colors.white.withValues(alpha: .05)
                                : Colors.white.withValues(alpha: .7)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .2),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Full Name
                                _buildLabel('Full Name'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: _inputDecoration(
                                    hint: 'Enter your full name',
                                    icon: Icons.person_outline,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Email
                                _buildLabel('Email Address'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) =>
                                      val!.isEmpty ? 'Required' : null,
                                  decoration: _inputDecoration(
                                    hint: 'name@example.com',
                                    icon: Icons.mail_outline,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Password
                                _buildLabel('Password'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  validator: (val) =>
                                      val!.length < 6 ? 'Min 6 chars' : null,
                                  decoration: _inputDecoration(
                                    hint: 'Min 8 characters',
                                    icon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () => setState(
                                        () => _isPasswordVisible =
                                            !_isPasswordVisible,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Submit Button
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.buttonGradient,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x332B4BEE),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 56,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: _signup,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            minimumSize: const Size(
                                              double.infinity,
                                              56,
                                            ),
                                          ),
                                          child: const Text('Create Account'),
                                        ),
                                ),
                                if (authProvider.status == AuthStatus.error &&
                                    authProvider.errorMessage != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: 16.0),
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            authProvider.errorMessage!,
                                            style: GoogleFonts.inter(
                                              color: Colors.red[700],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Social Divider
                    // SizedBox(
                    //   width: 480,
                    //   child: Column(
                    //     children: [
                    //       Row(
                    //         children: [
                    //           Expanded(child: Divider(color: AppColors.border)),
                    //           Padding(
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: 16,
                    //             ),
                    //             child: Text(
                    //               'OR JOIN WITH',
                    //               style: GoogleFonts.inter(
                    //                 fontSize: 12,
                    //                 fontWeight: FontWeight.w500,
                    //                 color: AppColors.textSecondary,
                    //                 letterSpacing: 1.0,
                    //               ),
                    //             ),
                    //           ),
                    //           Expanded(child: Divider(color: AppColors.border)),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 24),

                    //       // Social Buttons
                    //       Row(
                    //         spacing: 16,
                    //         children: [
                    //           Expanded(
                    //             child: _socialButton(
                    //               'Google',
                    //               'assets/icons/google.png',
                    //               null,
                    //             ),
                    //           ), // Placeholder icon logic
                    //           Expanded(
                    //             child: _socialButton(
                    //               'Apple',
                    //               null,
                    //               Icons.apple,
                    //             ),
                    //           ),
                    //         ],
                    //       ),

                    //       const SizedBox(height: 48),

                    //       // Footer
                    //       Text(
                    //         'Already have an account?',
                    //         style: TextStyle(
                    //           color: AppColors.textSecondary,
                    //           fontSize: 16,
                    //         ),
                    //       ),
                    //       GestureDetector(
                    //         onTap: () => context.go(AppRouteNames.login),
                    //         child: Text(
                    //           'Log in',
                    //           style: TextStyle(
                    //             color: AppColors.primary,
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 16,
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(height: 24),
                    //       Text(
                    //         'By joining, you agree to our\nTerms of Service and Privacy Policy.',
                    //         textAlign: TextAlign.center,
                    //         style: TextStyle(
                    //           color: AppColors.textSecondary,
                    //           fontSize: 12,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.8),
    );
  }

  Widget _socialButton(String label, String? assetPath, IconData? iconData) {
    // Simplified social button
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconData != null)
                Icon(iconData, size: 20, color: AppColors.textPrimary),
              if (iconData != null) const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
