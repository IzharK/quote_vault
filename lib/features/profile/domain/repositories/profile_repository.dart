import 'dart:io';
import 'package:quote_vault/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile(String userId);
  Future<void> updateProfile(Profile profile);
  Future<String> uploadAvatar(String userId, File imageFile);
}
