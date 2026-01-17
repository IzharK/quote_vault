import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/core/widgets/empty_state_view.dart';
import 'package:quote_vault/core/widgets/error_state_view.dart';
import 'package:quote_vault/features/quotes/presentation/providers/quote_provider.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/qod_widget.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuoteProvider>()
        ..fetchQuotes()
        ..loadQuoteOfTheDay();
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
      context.read<QuoteProvider>().fetchQuotes();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<QuoteProvider>().fetchQuotes(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeTitle)),
      body: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          if (provider.status == QuoteStatus.initial ||
              (provider.status == QuoteStatus.loading &&
                  provider.quotes.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == QuoteStatus.error && provider.quotes.isEmpty) {
            return ErrorStateView(
              message: provider.errorMessage,
              onRetry: _onRefresh,
            );
          }

          if (provider.status == QuoteStatus.loaded &&
              provider.quotes.isEmpty) {
            return const EmptyStateView(message: AppStrings.noQuotesFound);
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Consumer<QuoteProvider>(
                    builder: (context, provider, child) {
                      return QODWidget(
                        quote: provider.quoteOfTheDay,
                        isLoading: provider.isQodLoading,
                        onRetry: () => provider.loadQuoteOfTheDay(),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == provider.quotes.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return QuoteCard(quote: provider.quotes[index]);
                      },
                      childCount:
                          provider.quotes.length + (provider.hasMore ? 1 : 0),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
