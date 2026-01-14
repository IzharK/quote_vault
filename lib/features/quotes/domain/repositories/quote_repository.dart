import 'package:quote_vault/features/quotes/domain/entities/quote.dart';

abstract class QuoteRepository {
  Future<List<Quote>> getQuotes({required int page, required int pageSize});
}
