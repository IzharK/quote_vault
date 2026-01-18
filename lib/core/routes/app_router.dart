import 'package:go_router/go_router.dart';
import 'package:quote_vault/core/routes/route_names.dart';
import 'package:quote_vault/core/widgets/scaffold_with_nav_bar.dart';
import 'package:quote_vault/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:quote_vault/features/auth/presentation/pages/login_screen.dart';
import 'package:quote_vault/features/auth/presentation/pages/signup_screen.dart';
import 'package:quote_vault/features/auth/presentation/providers/auth_provider.dart';
import 'package:quote_vault/features/collections/presentation/pages/collection_detail_screen.dart';
import 'package:quote_vault/features/collections/presentation/pages/collections_screen.dart';
import 'package:quote_vault/features/favorites/presentation/pages/favorites_screen.dart';
import 'package:quote_vault/features/profile/presentation/pages/notifications_screen.dart';
import 'package:quote_vault/features/profile/presentation/pages/personal_information_screen.dart';
import 'package:quote_vault/features/profile/presentation/pages/profile_screen.dart';
import 'package:quote_vault/features/quotes/presentation/pages/category_screen.dart';
import 'package:quote_vault/features/quotes/presentation/pages/home_screen.dart';
import 'package:quote_vault/features/quotes/presentation/pages/search_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final router = GoRouter(
    initialLocation: AppRouteNames.home,
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
                path: AppRouteNames.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'category/:categoryId',
                    name: 'category',
                    builder: (context, state) => CategoryScreen(
                      categoryId: state.pathParameters['categoryId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.search,
                name: 'search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.favorites,
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'personal-info',
                    name: 'personal_info',
                    builder: (context, state) =>
                        const PersonalInformationScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    name: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRouteNames.collections,
        name: 'collections',
        builder: (context, state) => const CollectionsScreen(),
      ),
      GoRoute(
        path: '${AppRouteNames.collections}/:collectionId',
        name: 'collection_detail',
        builder: (context, state) => CollectionDetailScreen(
          collectionId: state.pathParameters['collectionId']!,
          collectionName: state.uri.queryParameters['name'] ?? 'Collection',
        ),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authProvider.status == AuthStatus.authenticated;
      final currentLoc = state.uri.toString();

      final isLoggingIn = currentLoc == AppRouteNames.login;
      final isSigningUp = currentLoc == AppRouteNames.signup;
      final isResettingPassword = currentLoc == AppRouteNames.forgotPassword;

      final isAuthPage = isLoggingIn || isSigningUp || isResettingPassword;

      if (!isLoggedIn && !isAuthPage) {
        return AppRouteNames.login;
      }

      if (isLoggedIn && isAuthPage) {
        return AppRouteNames.home;
      }

      return null;
    },
  );
}
