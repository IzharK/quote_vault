import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/widgets/share_options.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111218);
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF616889);

    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.white.withValues(alpha: .6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              offset: const Offset(0, 10),
              blurRadius: 40,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.amber.withValues(alpha: .2)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.quote.category.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: isDark ? Colors.amber[200] : const Color(0xFFB45309),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quote
              Text(
                '"${widget.quote.text}"',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),

              // Bottom Row: Author + Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Author
                  Expanded(
                    child: Text(
                      widget.quote.author.split(',').first,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),

                  // Actions
                  Row(
                    children: [
                      Consumer<FavoritesProvider>(
                        builder: (context, provider, child) {
                          final isFavorite = provider.isFavorite(
                            widget.quote.id,
                          );
                          return IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isFavorite ? Colors.red : subTextColor,
                              size: 22,
                            ),
                            onPressed: () =>
                                provider.toggleFavorite(widget.quote),
                            splashRadius: 20,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.ios_share,
                          color: subTextColor,
                          size: 22,
                        ),
                        onPressed: () => ShareOptions.showShareOptions(
                          context,
                          _globalKey,
                          widget.quote,
                        ),
                        splashRadius: 20,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
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
