import 'package:quote_vault/core/constants/supa_constants.dart';
import 'package:quote_vault/features/collections/data/models/collection_model.dart';
import 'package:quote_vault/features/collections/domain/entities/collection.dart';
import 'package:quote_vault/features/collections/domain/repositories/collection_repository.dart';
import 'package:quote_vault/features/quotes/data/models/quote_model.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final SupabaseClient _supabaseClient;

  CollectionRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Collection>> getCollections(String userId) async {
    final data = await _supabaseClient
        .from(SupaConstants.collectionsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> rows = data as List<dynamic>;
    return rows.map((row) => CollectionModel.fromJson(row)).toList();
  }

  @override
  Future<Collection> createCollection(String userId, String name) async {
    final data = await _supabaseClient
        .from(SupaConstants.collectionsTable)
        .insert({'user_id': userId, 'name': name})
        .select()
        .single();

    return CollectionModel.fromJson(data);
  }

  @override
  Future<void> updateCollection(String collectionId, String name) async {
    await _supabaseClient
        .from(SupaConstants.collectionsTable)
        .update({'name': name})
        .eq('id', collectionId);
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    await _supabaseClient
        .from(SupaConstants.collectionsTable)
        .delete()
        .eq('id', collectionId);
  }

  @override
  Future<List<Quote>> getCollectionQuotes(String collectionId) async {
    // Join collection_items with quotes
    final data = await _supabaseClient
        .from(SupaConstants.collectionItemsTable)
        .select('*, ${SupaConstants.quotesTable}(*)')
        .eq('collection_id', collectionId)
        .order('created_at', ascending: false);

    final List<dynamic> rows = data as List<dynamic>;
    return rows.map((row) {
      final quoteJson = row[SupaConstants.quotesTable] as Map<String, dynamic>;
      return QuoteModel.fromJson(quoteJson);
    }).toList();
  }

  @override
  Future<void> addQuoteToCollection(String collectionId, String quoteId) async {
    await _supabaseClient.from(SupaConstants.collectionItemsTable).insert({
      'collection_id': collectionId,
      'quote_id': quoteId,
    });
  }

  @override
  Future<void> removeQuoteFromCollection(
    String collectionId,
    String quoteId,
  ) async {
    await _supabaseClient
        .from(SupaConstants.collectionItemsTable)
        .delete()
        .match({'collection_id': collectionId, 'quote_id': quoteId});
  }
}
