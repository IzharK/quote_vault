import 'dart:developer';
import 'dart:io';

import 'package:quote_vault/core/constants/supa_constants.dart';
import 'package:quote_vault/features/profile/data/models/profile_model.dart';
import 'package:quote_vault/features/profile/domain/entities/profile.dart';
import 'package:quote_vault/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabaseClient;

  ProfileRepositoryImpl(this._supabaseClient);

  @override
  Future<Profile> getProfile(String userId) async {
    try {
      final data = await _supabaseClient
          .from(SupaConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();
      log('profile data: $data');
      return ProfileModel.fromJson(data);
    } catch (e) {
      log('profile not found in DB: $e. Falling back to Auth Metadata.');

      // Fallback: Check Auth User Metadata
      final user = _supabaseClient.auth.currentUser;
      if (user != null && user.id == userId) {
        String? fullName = user.userMetadata?['full_name'] as String?;
        if (fullName == null || fullName.isEmpty) {
          fullName = user.email?.split('@').first;
        }
        log('Found user in Auth Metadata: $fullName');

        final fallbackProfile = Profile(id: userId, fullName: fullName);

        // Auto-Sync: Create the missing row in 'profiles' table
        // This effectively "self-heals" the missing data issue.
        try {
          await updateProfile(fallbackProfile);
          log('Successfully synced Auth user to profiles table.');
        } catch (syncError) {
          log('Failed to sync user to profiles table: $syncError');
        }

        return fallbackProfile;
      }

      return Profile(id: userId);
    }
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    final model = ProfileModel.fromEntity(profile);
    await _supabaseClient
        .from(SupaConstants.profilesTable)
        .upsert(model.toJson());
  }

  @override
  Future<String> uploadAvatar(String userId, File imageFile) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName = '$userId-${DateTime.now().toIso8601String()}.$fileExt';
    final filePath = fileName; // Path inside the bucket

    await _supabaseClient.storage
        .from(SupaConstants.avatarsBucket)
        .upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final imageUrl = _supabaseClient.storage
        .from(SupaConstants.avatarsBucket)
        .getPublicUrl(filePath);
    return imageUrl;
  }
}
