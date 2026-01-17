import 'package:quote_vault/core/constants/supa_constants.dart';
import 'package:quote_vault/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:quote_vault/features/quotes/data/models/quote_model.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class FavoriteRepositoryImpl implements FavoriteRepository {
  final supa.SupabaseClient _supabaseClient;

  FavoriteRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Quote>> getFavorites(String userId) async {
    // Join favorites with quotes table
    final data = await _supabaseClient
        .from(SupaConstants.favoritesTable)
        .select('*, ${SupaConstants.quotesTable}(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> rows = data as List<dynamic>;
    return rows.map((row) {
      final quoteJson = row[SupaConstants.quotesTable] as Map<String, dynamic>;
      return QuoteModel.fromJson(quoteJson);
    }).toList();
  }

  @override
  Future<void> addFavorite(String userId, String quoteId) async {
    await _supabaseClient.from(SupaConstants.favoritesTable).insert({
      'user_id': userId,
      'quote_id': quoteId,
    });
  }

  @override
  Future<void> removeFavorite(String userId, String quoteId) async {
    await _supabaseClient.from(SupaConstants.favoritesTable).delete().match({
      'user_id': userId,
      'quote_id': quoteId,
    });
  }

  @override
  Future<Set<String>> getFavoriteIds(String userId) async {
    final data = await _supabaseClient
        .from(SupaConstants.favoritesTable)
        .select('quote_id')
        .eq('user_id', userId);

    final List<dynamic> rows = data as List<dynamic>;
    return rows.map((row) => row['quote_id'] as String).toSet();
  }
}
