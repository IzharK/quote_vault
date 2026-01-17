import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/widgets/empty_state_view.dart';
import 'package:quote_vault/core/widgets/error_state_view.dart';
import 'package:quote_vault/features/collections/presentation/providers/collection_provider.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_card.dart';

class CollectionDetailScreen extends StatefulWidget {
  final String collectionId;
  final String collectionName; // Pass name to avoid fetching collection details

  const CollectionDetailScreen({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  // We manage local state for the list of quotes here,
  // since the Provider doesn't cache per-collection lists globally.
  List<Quote>? _quotes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final quotes = await context
          .read<CollectionProvider>()
          .getCollectionQuotes(widget.collectionId);
      if (mounted) {
        setState(() {
          _quotes = quotes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeQuote(String quoteId) async {
    try {
      await context.read<CollectionProvider>().removeQuoteFromCollection(
        widget.collectionId,
        quoteId,
      );
      // Optimistic update locally
      setState(() {
        _quotes?.removeWhere((q) => q.id == quoteId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quote removed from collection')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove quote'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.collectionName)),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null) {
            return ErrorStateView(message: _error, onRetry: _loadQuotes);
          }

          if (_quotes == null || _quotes!.isEmpty) {
            return const EmptyStateView(
              message: 'No quotes in this collection yet.',
              icon: Icons.format_quote,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _quotes!.length,
            itemBuilder: (context, index) {
              final quote = _quotes![index];
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: QuoteCard(quote: quote),
                  ),
                  Positioned(
                    top: 0,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.grey),
                      tooltip: 'Remove from collection',
                      onPressed: () => _removeQuote(quote.id),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
