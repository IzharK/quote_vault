import 'package:quote_vault/features/quotes/data/models/quote_model.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:quote_vault/features/quotes/domain/repositories/quote_repository.dart';
import 'package:quote_vault/core/constants/supa_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuoteRepositoryImpl implements QuoteRepository {
  final SupabaseClient _supabaseClient;

  QuoteRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Quote>> getQuotes({
    required int page,
    required int pageSize,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final data = await _supabaseClient
        .from(SupaConstants.quotesTable)
        .select()
        .order('created_at', ascending: false)
        .range(from, to);

    final List<dynamic> jsonList = data;
    return jsonList.map((json) => QuoteModel.fromJson(json)).toList();
  }

  @override
  Future<List<Quote>> getQuotesByCategory({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final data = await _supabaseClient
        .from(SupaConstants.quotesTable)
        .select()
        .eq('category', category)
        .order('created_at', ascending: false)
        .range(from, to);

    final List<dynamic> jsonList = data;
    return jsonList.map((json) => QuoteModel.fromJson(json)).toList();
  }

  @override
  Future<List<Quote>> searchQuotes({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    // Searching text column using Full Text Search and author column using ILIKE
    final data = await _supabaseClient
        .from(SupaConstants.quotesTable)
        .select()
        .or('text.fts.$query,author.ilike.%$query%')
        .order('created_at', ascending: false)
        .range(from, to);

    final List<dynamic> jsonList = data;
    return jsonList.map((json) => QuoteModel.fromJson(json)).toList();
  }
}
