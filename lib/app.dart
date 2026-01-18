import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/di/injection_container.dart';
import 'package:quote_vault/core/routes/app_router.dart';
import 'package:quote_vault/core/theme/app_theme.dart';
import 'package:quote_vault/features/auth/presentation/providers/auth_provider.dart';
import 'package:quote_vault/features/collections/presentation/providers/collection_provider.dart';
import 'package:quote_vault/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:quote_vault/features/profile/presentation/providers/profile_provider.dart';
import 'package:quote_vault/features/quotes/presentation/providers/quote_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(InjectionContainer.authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProfileProvider(InjectionContainer.profileRepository, null),
        ),
        ChangeNotifierProvider(
          create: (_) => QuoteProvider(InjectionContainer.quoteRepository),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(
            InjectionContainer.favoriteRepository,
            '', // Initial empty ID
          ),
          update: (_, auth, prev) => FavoritesProvider(
            InjectionContainer.favoriteRepository,
            auth.user?.id ?? '',
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CollectionProvider>(
          create: (_) =>
              CollectionProvider(InjectionContainer.collectionRepository, ''),
          update: (_, auth, prev) => CollectionProvider(
            InjectionContainer.collectionRepository,
            auth.user?.id ?? '',
          ),
        ),
      ],
      child: const QuoteVaultApp(),
    );
  }
}

class QuoteVaultApp extends StatefulWidget {
  const QuoteVaultApp({super.key});

  @override
  State<QuoteVaultApp> createState() => _QuoteVaultAppState();
}

class _QuoteVaultAppState extends State<QuoteVaultApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    // Initialize AppRouter once.
    // It listens to AuthProvider internally via refreshListenable, so we don't need to recreate it.
    _appRouter = AppRouter(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QuoteVault',
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
