import 'dart:io';
import 'package:quote_vault/features/profile/data/models/profile_model.dart';
import 'package:quote_vault/features/profile/domain/entities/profile.dart';
import 'package:quote_vault/features/profile/domain/repositories/profile_repository.dart';
import 'package:quote_vault/core/constants/supa_constants.dart';
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
      return ProfileModel.fromJson(data);
    } catch (e) {
      // If profile doesn't exist, return empty profile with just ID
      // This handles the case where trigger failed or user wasn't created in profiles table properly
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
