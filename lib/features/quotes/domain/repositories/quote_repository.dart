import 'package:quote_vault/features/quotes/domain/entities/quote.dart';

abstract class QuoteRepository {
  Future<List<Quote>> getQuotes({required int page, required int pageSize});
  Future<List<Quote>> getQuotesByCategory({
    required String category,
    required int page,
    required int pageSize,
  });
  Future<List<Quote>> searchQuotes({
    required String query,
    required int page,
    required int pageSize,
  });
  Future<Quote> getRandomQuote();
}
