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

  // Category
  QuoteStatus _categoryStatus = QuoteStatus.initial;
  QuoteStatus get categoryStatus => _categoryStatus;

  final List<Quote> _categoryQuotes = [];
  List<Quote> get categoryQuotes => _categoryQuotes;

  bool _categoryHasMore = true;
  bool get categoryHasMore => _categoryHasMore;

  int _categoryPage = 0;
  String? _currentCategory;

  Future<void> fetchQuotesByCategory(
    String category, {
    bool refresh = false,
  }) async {
    if (refresh || category != _currentCategory) {
      _categoryPage = 0;
      _categoryQuotes.clear();
      _categoryHasMore = true;
      _categoryStatus = QuoteStatus.initial;
      _currentCategory = category;
    }

    if (_categoryStatus == QuoteStatus.loading || !_categoryHasMore) return;

    _categoryStatus = QuoteStatus.loading;
    notifyListeners();

    try {
      final newQuotes = await _quoteRepository.getQuotesByCategory(
        category: category,
        page: _categoryPage,
        pageSize: _pageSize,
      );

      if (newQuotes.isEmpty) {
        _categoryHasMore = false;
      } else {
        _categoryQuotes.addAll(newQuotes);
        _categoryPage++;
        if (newQuotes.length < _pageSize) {
          _categoryHasMore = false;
        }
      }

      _categoryStatus = QuoteStatus.loaded;
    } catch (e) {
      _categoryStatus = QuoteStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // Search
  QuoteStatus _searchStatus = QuoteStatus.initial;
  QuoteStatus get searchStatus => _searchStatus;

  final List<Quote> _searchResults = [];
  List<Quote> get searchResults => _searchResults;

  bool _searchHasMore = true;
  bool get searchHasMore => _searchHasMore;

  int _searchPage = 0;
  String? _currentQuery;

  Future<void> searchQuotes(String query, {bool refresh = false}) async {
    if (query.isEmpty) {
      _searchResults.clear();
      _searchStatus = QuoteStatus.initial;
      notifyListeners();
      return;
    }

    if (refresh || query != _currentQuery) {
      _searchPage = 0;
      _searchResults.clear();
      _searchHasMore = true;
      _searchStatus = QuoteStatus.initial;
      _currentQuery = query;
    }

    if (_searchStatus == QuoteStatus.loading || !_searchHasMore) return;

    _searchStatus = QuoteStatus.loading;
    notifyListeners();

    try {
      final newQuotes = await _quoteRepository.searchQuotes(
        query: query,
        page: _searchPage,
        pageSize: _pageSize,
      );

      if (newQuotes.isEmpty) {
        _searchHasMore = false;
      } else {
        _searchResults.addAll(newQuotes);
        _searchPage++;
        if (newQuotes.length < _pageSize) {
          _searchHasMore = false;
        }
      }

      _searchStatus = QuoteStatus.loaded;
    } catch (e) {
      _searchStatus = QuoteStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
