import 'package:flutter/material.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:quote_vault/features/quotes/domain/repositories/quote_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuoteStatus { initial, loading, loaded, error }

class QuoteProvider extends ChangeNotifier {
  final QuoteRepository _quoteRepository;

  QuoteStatus _status = QuoteStatus.initial;
  QuoteStatus get status => _status;

  final List<Quote> _quotes = [];
  List<Quote> get quotes => _quotes;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isQodLoading = false;
  bool get isQodLoading => _isQodLoading;

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

  // --- QOD ---
  Quote? _quoteOfTheDay;
  Quote? get quoteOfTheDay => _quoteOfTheDay;

  Future<void> loadQuoteOfTheDay() async {
    _isQodLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      const keyDate = 'qod_date';
      const keyId = 'qod_id';

      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final savedDate = prefs.getString(keyDate);
      final savedId = prefs.getString(keyId);

      if (savedDate == todayStr && savedId != null) {
        // Try to fetch specific quote if we had getQuoteById, but we don't have it exposed efficiently yet.
        // Or we could have saved the whole quote JSON string to avoid network call.
        // Let's implement simpler: Fetch random always if not cached locally?
        // No, QOD must be constant for the day.
        // Let's save the JSON of QOD to avoid complexities with ID fetching if possible.
        // Or blindly fetch random if logic fails.
        // Actually, let's just fetch random for this implementation to keep it simple,
        // BUT respecting the "Day" constraint is key.
        // Since we don't have 'getQuoteById', saving just ID is risky if we can't fetch it easily.
        // Let's save JSON payload in SharedPrefs.

        final savedJson = prefs.getString('qod_json');
        if (savedJson != null) {
          // Need to decode logic but jsonEncode needed.
          // Let's rely on Repo.getRandomQuote() for now and save date.
          // IF date matches, do we re-fetch same? No, random will give DIFFERENT.
          // We MUST cache the quote content locally.
          // Re-reading JSON requires dart:convert.
        }
      }

      // Simplified approach: ALWAYS fetch random for now until we add local caching logic properly.
      // Wait, user asked for "Quote of the Day logic".
      // Logic:
      // 1. Check Date & Cached Quote
      // 2. If valid, use Cached.
      // 3. If invalid, Fetch Random -> Cache Date & Quote.

      final today = DateTime.now();
      final todayKey = "${today.year}-${today.month}-${today.day}";
      final lastDate = prefs.getString('last_qod_date');
      final lastQuoteText = prefs.getString('last_qod_text');
      final lastQuoteAuthor = prefs.getString('last_qod_author');
      final lastQuoteId = prefs.getString('last_qod_id');
      final lastQuoteCategory = prefs.getString('last_qod_category');

      if (lastDate == todayKey &&
          lastQuoteText != null &&
          lastQuoteId != null) {
        _quoteOfTheDay = Quote(
          id: lastQuoteId,
          text: lastQuoteText,
          author: lastQuoteAuthor ?? 'Unknown',
          category: lastQuoteCategory ?? 'General',
        );
      } else {
        final quote = await _quoteRepository.getRandomQuote();
        _quoteOfTheDay = quote;

        // Save
        await prefs.setString('last_qod_date', todayKey);
        await prefs.setString('last_qod_text', quote.text);
        await prefs.setString('last_qod_author', quote.author);
        await prefs.setString('last_qod_id', quote.id);
        await prefs.setString('last_qod_category', quote.category);
      }
    } catch (e) {
      _errorMessage = "Failed to load QOD";
    } finally {
      _isQodLoading = false;
      notifyListeners();
    }
  }

  // --- Search & Category ---
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
