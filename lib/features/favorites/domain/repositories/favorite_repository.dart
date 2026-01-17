import 'package:quote_vault/features/quotes/domain/entities/quote.dart';

abstract class FavoriteRepository {
  Future<List<Quote>> getFavorites(String userId);
  Future<void> addFavorite(String userId, String quoteId);
  Future<void> removeFavorite(String userId, String quoteId);
  Future<Set<String>> getFavoriteIds(String userId);
}
