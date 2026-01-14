import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/features/quotes/presentation/providers/quote_provider.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<QuoteProvider>().searchQuotes(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<QuoteProvider>().searchQuotes(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Quotes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for quotes or authors...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          if (provider.searchStatus == QuoteStatus.initial &&
              provider.searchResults.isEmpty &&
              _searchController.text.isEmpty) {
            return const Center(child: Text('Type to search...'));
          }

          if (provider.searchStatus == QuoteStatus.loading &&
              provider.searchResults.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.searchStatus == QuoteStatus.error &&
              provider.searchResults.isEmpty) {
            return Center(
              child: Text(
                provider.errorMessage ?? AppStrings.errorGeneric,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.searchResults.isEmpty &&
              _searchController.text.isNotEmpty &&
              provider.searchStatus == QuoteStatus.loaded) {
            return const Center(child: Text('No results found.'));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount:
                provider.searchResults.length +
                (provider.searchHasMore ? 1 : 0),
            padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
            itemBuilder: (context, index) {
              if (index == provider.searchResults.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return QuoteCard(quote: provider.searchResults[index]);
            },
          );
        },
      ),
    );
  }
}
