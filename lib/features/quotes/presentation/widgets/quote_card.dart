import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/services/share_service.dart';
import 'package:quote_vault/features/collections/presentation/widgets/add_to_collection_sheet.dart';
import 'package:quote_vault/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';

class QuoteCard extends StatefulWidget {
  final Quote quote;

  const QuoteCard({super.key, required this.quote});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  final GlobalKey _globalKey = GlobalKey();

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Share as Text'),
              onTap: () {
                Navigator.pop(context);
                ShareService.shareText(
                  quote: widget.quote.text,
                  author: widget.quote.author,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Share as Image'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ShareService.shareWidgetImage(
                    globalKey: _globalKey,
                    quoteId: widget.quote.id,
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to share image: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Chip
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    'category',
                    pathParameters: {'categoryId': widget.quote.category},
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    widget.quote.category.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Quote Text
              Text(
                '"${widget.quote.text}"',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16.0),

              // Author
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '- ${widget.quote.author}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<FavoritesProvider>(
                    builder: (context, provider, child) {
                      final isFavorite = provider.isFavorite(widget.quote.id);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          provider.toggleFavorite(widget.quote);
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) =>
                            AddToCollectionSheet(quoteId: widget.quote.id),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _showShareOptions,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
