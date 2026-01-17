import 'package:flutter/material.dart';
import 'package:quote_vault/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoriteRepository _favoriteRepository;
  final String _userId;

  FavoritesProvider(this._favoriteRepository, this._userId) {
    loadFavorites();
  }

  Set<String> _favoriteIds = {};
  Set<String> get favoriteIds => _favoriteIds;

  List<Quote> _favorites = [];
  List<Quote> get favorites => _favorites;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Parallel fetch could be better but let's do sequential for simplicity
      // Or derived. Repository getFavorites returns List<Quote>.
      // Repository getFavoriteIds returns Set<String>.
      // We can fetch full list and map to IDs to avoid 2 calls if list is fetched.
      // But for "Heart Status", we just need IDs.
      // Let's fetch FULL list for now as list size is small per user usually.

      final favs = await _favoriteRepository.getFavorites(_userId);
      _favorites = favs;
      _favoriteIds = favs.map((e) => e.id).toSet();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String quoteId) => _favoriteIds.contains(quoteId);

  Future<void> toggleFavorite(Quote quote) async {
    final isFav = isFavorite(quote.id);

    // Optimistic Update
    if (isFav) {
      _favoriteIds.remove(quote.id);
      _favorites.removeWhere((element) => element.id == quote.id);
    } else {
      _favoriteIds.add(quote.id);
      _favorites.insert(0, quote); // Add to top
    }
    notifyListeners();

    try {
      if (isFav) {
        await _favoriteRepository.removeFavorite(_userId, quote.id);
      } else {
        await _favoriteRepository.addFavorite(_userId, quote.id);
      }
    } catch (e) {
      // Revert on failure
      if (isFav) {
        _favoriteIds.add(quote.id);
        _favorites.insert(0, quote); // Approximate position restoration
      } else {
        _favoriteIds.remove(quote.id);
        _favorites.removeWhere((element) => element.id == quote.id);
      }
      _errorMessage = "Failed to update favorite";
      notifyListeners();
    }
  }
}
