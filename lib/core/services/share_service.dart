import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Shares just the text of the quote.
  static Future<void> shareText({
    required String quote,
    required String author,
    BuildContext? context, // For iPad popover info if needed
  }) async {
    final text = '"$quote"\n\n- $author\n\nShared via QuoteVault';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Captures a widget as an image and shares it.
  /// [globalKey] must be attached to a RepaintBoundary wrapping the content.
  static Future<void> shareWidgetImage({
    required GlobalKey globalKey,
    required String quoteId,
  }) async {
    try {
      final boundary =
          globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception("Unable to find render boundary");
      }

      // Capture image (pixelRatio 3.0 for high quality)
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/quote_$quoteId.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes);

      final xFile = XFile(path);
      await SharePlus.instance.share(ShareParams(files: [xFile]));
    } catch (e) {
      debugPrint('Error sharing image: $e');
      // Rethrow so UI can handle/show toast
      rethrow;
    }
  }
}
