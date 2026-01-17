import 'package:quote_vault/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quote_vault/features/auth/domain/repositories/auth_repository.dart';
import 'package:quote_vault/features/collections/data/repositories/collection_repository_impl.dart';
import 'package:quote_vault/features/collections/domain/repositories/collection_repository.dart';
import 'package:quote_vault/features/favorites/data/repositories/favorite_repository_impl.dart';
import 'package:quote_vault/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:quote_vault/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:quote_vault/features/profile/domain/repositories/profile_repository.dart';
import 'package:quote_vault/features/quotes/data/repositories/quote_repository_impl.dart';
import 'package:quote_vault/features/quotes/domain/repositories/quote_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InjectionContainer {
  static late final AuthRepository authRepository;
  static late final ProfileRepository profileRepository;
  static late final QuoteRepository quoteRepository;
  static late final FavoriteRepository favoriteRepository;
  static late final CollectionRepository collectionRepository;

  static void init() {
    final supabaseClient = Supabase.instance.client;

    authRepository = AuthRepositoryImpl(supabaseClient);
    profileRepository = ProfileRepositoryImpl(supabaseClient);
    quoteRepository = QuoteRepositoryImpl(supabaseClient);
    favoriteRepository = FavoriteRepositoryImpl(supabaseClient);
    collectionRepository = CollectionRepositoryImpl(supabaseClient);
  }
}
