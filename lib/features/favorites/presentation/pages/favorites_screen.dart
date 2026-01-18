import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quote_vault/core/routes/route_names.dart';
import 'package:quote_vault/core/widgets/background_gradient.dart';
import 'package:quote_vault/core/widgets/empty_state_view.dart';
import 'package:quote_vault/core/widgets/error_state_view.dart';
import 'package:quote_vault/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:quote_vault/features/quotes/presentation/widgets/quote_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger load on build if empty? Or provider does it on init.
    // Provider init does it, but we update provider on auth change.
    // So logic should hold.

    final provider = context.watch<FavoritesProvider>();
    final favorites = provider.favorites;
    final isLoading = provider.isLoading;
    final errorMessage = provider.errorMessage;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => context.push(AppRouteNames.collections),
            tooltip: 'My Collections',
          ),
        ],
      ),
      body: BackgroundGradient(
        child: Builder(
          builder: (context) {
            final topPadding =
                MediaQuery.of(context).padding.top + kToolbarHeight;

            if (isLoading && favorites.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (errorMessage != null && favorites.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: ErrorStateView(
                  message: errorMessage,
                  onRetry: () =>
                      context.read<FavoritesProvider>().loadFavorites(),
                ),
              );
            }

            if (favorites.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: const EmptyStateView(
                  message: 'No favorites yet.',
                  icon: Icons.favorite_border,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<FavoritesProvider>().loadFavorites(),
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top: topPadding + 16,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final quote = favorites[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: QuoteCard(quote: quote),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
