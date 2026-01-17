import 'package:flutter/material.dart';
import 'package:quote_vault/features/collections/domain/entities/collection.dart';
import 'package:quote_vault/features/collections/domain/repositories/collection_repository.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';

class CollectionProvider extends ChangeNotifier {
  final CollectionRepository _collectionRepository;
  final String _userId;

  CollectionProvider(this._collectionRepository, this._userId) {
    if (_userId.isNotEmpty) {
      loadCollections();
    }
  }

  List<Collection> _collections = [];
  List<Collection> get collections => _collections;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadCollections() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _collections = await _collectionRepository.getCollections(_userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCollection(String name) async {
    try {
      final newCollection = await _collectionRepository.createCollection(
        _userId,
        name,
      );
      _collections.insert(0, newCollection);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to create collection: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCollection(String id, String newName) async {
    try {
      await _collectionRepository.updateCollection(id, newName);
      final index = _collections.indexWhere((c) => c.id == id);
      if (index != -1) {
        // Create new object with updated name since Entity is immutable?
        // Wait, I didn't add copyWith to Collection entity.
        // Let's create a new Collection instance manually or implementing copyWith.
        // For now manual copy.
        final old = _collections[index];
        _collections[index] = Collection(
          id: old.id,
          userId: old.userId,
          name: newName,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to update collection";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCollection(String id) async {
    try {
      await _collectionRepository.deleteCollection(id);
      _collections.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to delete collection";
      rethrow;
    }
  }

  // --- Collection Items ---

  Future<List<Quote>> getCollectionQuotes(String collectionId) async {
    try {
      return await _collectionRepository.getCollectionQuotes(collectionId);
    } catch (e) {
      // Return empty list or rethrow? Let's rethrow for UI to handle error state
      rethrow;
    }
  }

  Future<void> addQuoteToCollection(String collectionId, String quoteId) async {
    try {
      await _collectionRepository.addQuoteToCollection(collectionId, quoteId);
      // We don't cache items locally in this provider list yet, so just notify listeners or nothing.
      // If we are viewing the detail screen, it should probably reload.
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeQuoteFromCollection(
    String collectionId,
    String quoteId,
  ) async {
    try {
      await _collectionRepository.removeQuoteFromCollection(
        collectionId,
        quoteId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
