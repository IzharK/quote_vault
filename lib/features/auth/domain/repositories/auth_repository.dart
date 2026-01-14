import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> signInWithEmail(String email, String password);
  Future<AuthResponse> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> resetPasswordForEmail(String email);
  Session? getCurrentSession();
  User? getCurrentUser();
  Stream<AuthState> get authStateChanges;
}
