import 'package:flutter/material.dart';
import 'package:quote_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._authRepository) {
    _init();
  }

  void _init() {
    _user = _authRepository.getCurrentUser();
    _status = _user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    _authRepository.authStateChanges.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _user = session.user;
        _status = AuthStatus.authenticated;
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      print("Attempting to sign in: $email");
      await _authRepository.signInWithEmail(email, password);
      print("Sign in successful call");
      // Status update handled by stream listener
    } catch (e) {
      print("Sign in error: $e");
      _status = AuthStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, {String? name}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      print("Attempting to sign up: $email");
      final response = await _authRepository.signUpWithEmail(
        email,
        password,
        name: name,
      );
      print("Sign up response user: ${response.user?.id}");
      // Status update handled by stream listener

      // Safety/Manual update if stream is slow?
      if (response.user != null && _user == null) {
        // Stream *should* handle this, but if not, we wait.
      }
    } catch (e) {
      print("Sign up error: $e");
      _status = AuthStatus.error;
      _errorMessage = _parseError(e); // Helper to make cleaner errors
      notifyListeners();

      // Do NOT immediately revert to unauthenticated, let the UI consume the error.
      // But verify how UI consumes it. Usage of Consumer might re-build.
      // If we don't revert, the spinner stops (status != loading).
    }
  }

  String _parseError(Object error) {
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<void> resetPassword(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPasswordForEmail(email);
      _status = AuthStatus.unauthenticated; // Stays unauthenticated
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
}
