import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quote_vault/features/profile/domain/entities/profile.dart';
import 'package:quote_vault/features/profile/domain/repositories/profile_repository.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final String? _userId;

  ProfileStatus _status = ProfileStatus.initial;
  ProfileStatus get status => _status;

  Profile? _profile;
  Profile? get profile => _profile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileProvider(this._profileRepository, this._userId);

  Future<void> loadProfile() async {
    final userId = _userId;
    if (userId == null) return;

    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      _profile = await _profileRepository.getProfile(userId);
      _status = ProfileStatus.loaded;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> updateName(String fullName) async {
    if (_profile == null) return;

    final updatedProfile = _profile!.copyWith(fullName: fullName);
    await _updateProfile(updatedProfile);
  }

  Future<void> updateAvatar(File imageFile) async {
    final userId = _userId;
    final profile = _profile;
    if (profile == null || userId == null) return;

    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      final avatarUrl = await _profileRepository.uploadAvatar(
        userId,
        imageFile,
      );
      final updatedProfile = profile.copyWith(avatarUrl: avatarUrl);
      await _profileRepository.updateProfile(updatedProfile);
      _profile = updatedProfile;
      _status = ProfileStatus.loaded;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> _updateProfile(Profile profile) async {
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      await _profileRepository.updateProfile(profile);
      _profile = profile;
      _status = ProfileStatus.loaded;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
