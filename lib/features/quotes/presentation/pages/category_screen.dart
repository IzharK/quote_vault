import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/features/quotes/presentation/providers/quote_provider.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_card.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryId;

  const CategoryScreen({super.key, required this.categoryId});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuoteProvider>().fetchQuotesByCategory(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<QuoteProvider>().fetchQuotesByCategory(widget.categoryId);
    }
  }

  Future<void> _onRefresh() async {
    await context.read<QuoteProvider>().fetchQuotesByCategory(
      widget.categoryId,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryId.toUpperCase())),
      body: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          if (provider.categoryStatus == QuoteStatus.initial ||
              (provider.categoryStatus == QuoteStatus.loading &&
                  provider.categoryQuotes.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categoryStatus == QuoteStatus.error &&
              provider.categoryQuotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage ?? AppStrings.errorGeneric,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  provider.categoryQuotes.length +
                  (provider.categoryHasMore ? 1 : 0),
              padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
              itemBuilder: (context, index) {
                if (index == provider.categoryQuotes.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return QuoteCard(quote: provider.categoryQuotes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
