import 'package:flutter/material.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:quote_vault/features/quotes/domain/repositories/quote_repository.dart';

enum QuoteStatus { initial, loading, loaded, error }

class QuoteProvider extends ChangeNotifier {
  final QuoteRepository _quoteRepository;

  QuoteStatus _status = QuoteStatus.initial;
  QuoteStatus get status => _status;

  final List<Quote> _quotes = [];
  List<Quote> get quotes => _quotes;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _currentPage = 0;
  static const int _pageSize = 10;

  QuoteProvider(this._quoteRepository);

  Future<void> fetchQuotes({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _quotes.clear();
      _hasMore = true;
      _status = QuoteStatus.initial;
    }

    if (_status == QuoteStatus.loading || !_hasMore) return;

    _status = QuoteStatus.loading;
    notifyListeners();

    try {
      final newQuotes = await _quoteRepository.getQuotes(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (newQuotes.isEmpty) {
        _hasMore = false;
      } else {
        _quotes.addAll(newQuotes);
        _currentPage++;
        if (newQuotes.length < _pageSize) {
          _hasMore = false;
        }
      }

      _status = QuoteStatus.loaded;
    } catch (e) {
      _status = QuoteStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
