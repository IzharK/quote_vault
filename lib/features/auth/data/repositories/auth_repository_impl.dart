import 'dart:developer';

import 'package:quote_vault/core/constants/supa_constants.dart';
import 'package:quote_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    final res = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    log('login response: ${res.user?.toJson()}');
    return res;
  }

  @override
  Future<AuthResponse> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'full_name': name} : null,
    );

    if (response.user != null) {
      try {
        await _supabaseClient.from(SupaConstants.profilesTable).upsert({
          'id': response.user!.id,
          'full_name': name,
          'email': email,
        });
        log('Profile created successfully for user: ${response.user!.id}');
      } catch (e) {
        log('Error creating profile record: $e');
      }
    }

    return response;
  }

  @override
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  @override
  Session? getCurrentSession() {
    return _supabaseClient.auth.currentSession;
  }

  @override
  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  @override
  Stream<AuthState> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange;
  }
}
