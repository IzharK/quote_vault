import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/features/auth/presentation/providers/auth_provider.dart';
import 'package:quote_vault/features/profile/presentation/providers/profile_provider.dart';
import 'package:quote_vault/features/profile/presentation/widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (_nameController.text.isNotEmpty) {
      await context.read<ProfileProvider>().updateName(
        _nameController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.profileUpdated)),
        );
      }
    }
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
    // GoRouter redirect will handle navigation
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final isLoading = profileProvider.status == ProfileStatus.loading;

    // Pre-fill controller if empty and profile has name
    if (_nameController.text.isEmpty && profile?.fullName != null) {
      _nameController.text = profile!.fullName!;
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle)),
      body:
          isLoading &&
              profile ==
                  null // Only show full loader if no profile loaded yet
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (profileProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        profileProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ProfileAvatar(
                    avatarUrl: profile?.avatarUrl,
                    onTap: _pickImage,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text(AppStrings.changeAvatarButton),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.fullNameLabel,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading ? null : _updateName,
                    child: const Text(AppStrings.updateNameButton),
                  ),
                  const SizedBox(height: 48),
                  OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text(AppStrings.signOutButton),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
