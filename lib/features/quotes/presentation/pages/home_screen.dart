import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/widgets/background_gradient.dart';
import 'package:quote_vault/features/quotes/presentation/providers/quote_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuoteProvider>().loadQuoteOfTheDay();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<QuoteProvider>().loadQuoteOfTheDay();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuoteProvider>();
    final qod = provider.quoteOfTheDay;
    final isLoading = provider.isQodLoading;

    final qodAuthor = qod?.author.split(',').first;
    final qodSection = qod?.author.split(',  ').last;
    // Font Styles from HTML/Design
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : const Color(0xFF2C2C2C); // Charcoal

    return Scaffold(
      extendBodyBehindAppBar: true,
      // No Standard AppBar - we use custom controls overlay
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background
          const BackgroundGradient(),

          // 2. Main Content
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (qod == null)
            // Error / Empty State
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 48,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Quote Available",
                    style: TextStyle(color: textColor.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _onRefresh, child: const Text("Retry")),
                ],
              ),
            )
          else
            Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Today's Wisdom" Label
                  Text(
                    "TODAY'S WISDOM",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.2,
                      color: textColor.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Giant Quote Icon
                      Positioned(
                        top: -50,
                        left: -20,
                        child: Icon(
                          Icons.format_quote,
                          size: 96,
                          color: textColor.withValues(alpha: 0.05),
                        ),
                      ),

                      // Quote Text
                      Text(
                        qod.text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Divider
                  Container(
                    height: 1,
                    width: 40,
                    color: textColor.withValues(alpha: 0.2),
                  ),

                  const SizedBox(height: 16),

                  // Author
                  Text(
                    '$qodAuthor\n$qodSection',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tags (Pills)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildTag(qod.category, textColor),
                      // If we had more tags, we'd map them here
                    ],
                  ),
                ],
              ),
            ),

          // 3. Top Right Actions
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            right: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Quote Vault',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildActionButton(Icons.bookmark_outline, () {}),
                const SizedBox(width: 16),
                _buildActionButton(Icons.ios_share_rounded, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        // backdrop blur handled by background usually, but here just opacity
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: textColor.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    // Glassmorphic button
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: const Color(0xFF2C2C2C), size: 24),
      ),
    );
  }
}
