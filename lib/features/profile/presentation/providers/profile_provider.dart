import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quote_vault/features/profile/domain/entities/profile.dart';
import 'package:quote_vault/features/profile/domain/repositories/profile_repository.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  String? _userId;

  ProfileStatus _status = ProfileStatus.initial;
  ProfileStatus get status => _status;

  Profile? _profile;
  Profile? get profile => _profile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileProvider(this._profileRepository, this._userId) {
    if (_userId != null) {
      loadProfile();
    }
  }

  Future<void> loadProfile({String? userId}) async {
    if (userId != null) {
      _userId = userId;
    }

    final id = _userId;
    if (id == null) return;

    _status = ProfileStatus.loading;
    notifyListeners();
    log('loading profile for user: $id');

    try {
      _profile = await _profileRepository.getProfile(id);
      _status = ProfileStatus.loaded;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> updateName(String fullName) async {
    if (_profile == null) {
      if (_userId != null) {
        _profile = Profile(id: _userId!);
      } else {
        throw Exception("User ID not available. Please try logging in again.");
      }
    }

    final updatedProfile = _profile!.copyWith(fullName: fullName);
    await _updateProfile(updatedProfile);
  }

  Future<void> updateAvatar(File imageFile) async {
    final userId = _userId;
    // Handle profile being null by creating temporary one if userId exists
    if (_profile == null && userId != null) {
      _profile = Profile(id: userId);
    }

    final profile = _profile;
    if (profile == null || userId == null) {
      throw Exception("User ID not available.");
    }

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
      notifyListeners();
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _updateProfile(Profile profile) async {
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      await _profileRepository.updateProfile(profile);
      _profile = profile;
      _status = ProfileStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
