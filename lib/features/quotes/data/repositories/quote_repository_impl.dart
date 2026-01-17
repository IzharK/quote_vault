import 'dart:math';

import 'package:quote_vault/core/constants/supa_constants.dart';
import 'package:quote_vault/features/quotes/data/models/quote_model.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:quote_vault/features/quotes/domain/repositories/quote_repository.dart';
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

  @override
  Future<Quote> getRandomQuote() async {
    // 1. Get total count
    final countResponse = await _supabaseClient
        .from(SupaConstants.quotesTable)
        .count();

    // count() returns int directly
    final count = countResponse;

    if (count == 0) {
      throw Exception('No quotes available');
    }

    // 2. Random offset
    // Ensure we don't exceed capabilities if count is very large, but simple offset is fine for our scale.
    final randomOffset = Random().nextInt(count);

    // 3. Fetch 1 quote at offset
    final data = await _supabaseClient
        .from(SupaConstants.quotesTable)
        .select()
        .range(randomOffset, randomOffset)
        .single();

    return QuoteModel.fromJson(data);
  }
}
