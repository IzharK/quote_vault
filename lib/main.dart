import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/constants/supa_constants.dart';
import 'package:quote_vault/core/routes/app_router.dart';
import 'package:quote_vault/core/theme/app_theme.dart';
import 'package:quote_vault/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quote_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:quote_vault/features/auth/presentation/providers/auth_provider.dart';
import 'package:quote_vault/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:quote_vault/features/profile/domain/repositories/profile_repository.dart';
import 'package:quote_vault/features/profile/presentation/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupaConstants.supabaseUrl,
    anonKey: SupaConstants.supabaseAnonKey,
  );

  final supabaseClient = Supabase.instance.client;
  final authRepository = AuthRepositoryImpl(supabaseClient);
  final profileRepository = ProfileRepositoryImpl(supabaseClient);

  runApp(
    MyApp(authRepository: authRepository, profileRepository: profileRepository),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(profileRepository, null),
          update: (_, auth, prev) =>
              ProfileProvider(profileRepository, auth.user?.id),
        ),
      ],
      child: Builder(
        // Need Builder to get context with Provider for AppRouter if we want refreshListenable
        builder: (context) {
          // To make refreshListenable work, we need to reconstruct GoRouter or pass the provider.
          // Simplest way: access provider here and pass to a method that creates router.
          // Or just update AppRouter to accept provider.
          // For this step, I'll update AppRouter to be a class that accepts provider.
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
