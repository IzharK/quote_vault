import 'package:quote_vault/features/collections/domain/entities/collection.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';

abstract class CollectionRepository {
  Future<List<Collection>> getCollections(String userId);
  Future<Collection> createCollection(String userId, String name);
  Future<void> updateCollection(String collectionId, String name);
  Future<void> deleteCollection(String collectionId);
  Future<List<Quote>> getCollectionQuotes(String collectionId);
  Future<void> addQuoteToCollection(String collectionId, String quoteId);
  Future<void> removeQuoteFromCollection(String collectionId, String quoteId);
}
