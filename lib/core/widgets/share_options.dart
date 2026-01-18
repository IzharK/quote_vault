import 'package:flutter/material.dart';
import 'package:quote_vault/core/services/share_service.dart';
import 'package:quote_vault/features/quotes/domain/entities/quote.dart';

class ShareOptions {
  static void showShareOptions(
    BuildContext context,
    GlobalKey globalKey,
    Quote quote,
  ) {
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
                ShareService.shareText(quote: quote.text, author: quote.author);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Share as Image'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ShareService.shareWidgetImage(
                    globalKey: globalKey,
                    quoteId: quote.id,
                  );
                } catch (e) {
                  if (context.mounted) {
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
}
