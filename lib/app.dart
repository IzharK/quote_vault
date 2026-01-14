import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/di/injection_container.dart';
import 'package:quote_vault/core/routes/app_router.dart';
import 'package:quote_vault/core/theme/app_theme.dart';
import 'package:quote_vault/features/auth/presentation/providers/auth_provider.dart';
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
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) =>
              ProfileProvider(InjectionContainer.profileRepository, null),
          update: (_, auth, prev) => ProfileProvider(
            InjectionContainer.profileRepository,
            auth.user?.id,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => QuoteProvider(InjectionContainer.quoteRepository),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'QuoteVault',
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter(context.read<AuthProvider>()).router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
