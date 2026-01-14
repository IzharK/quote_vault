import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:quote_vault/core/widgets/scaffold_with_nav_bar.dart';
import 'package:quote_vault/features/auth/presentation/pages/login_screen.dart';
import 'package:quote_vault/features/auth/presentation/pages/signup_screen.dart';
import 'package:quote_vault/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:quote_vault/features/auth/presentation/providers/auth_provider.dart';
import 'package:quote_vault/features/profile/presentation/pages/profile_screen.dart';
import 'package:quote_vault/features/quotes/presentation/pages/home_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final router = GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Search Screen Placeholder')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collections',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Collections Screen Placeholder')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authProvider.status == AuthStatus.authenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isResettingPassword = state.uri.toString() == '/forgot-password';

      if (!isLoggedIn && !isLoggingIn && !isSigningUp && !isResettingPassword) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isSigningUp || isResettingPassword)) {
        return '/';
      }

      return null;
    },
  );
}
