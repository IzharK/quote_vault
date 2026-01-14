import 'package:quote_vault/features/quotes/domain/entities/quote.dart';

class QuoteModel extends Quote {
  const QuoteModel({
    required super.id,
    required super.text,
    required super.author,
    required super.category,
    super.tags,
    super.popularity,
    super.source,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      popularity: (json['popularity'] as num?)?.toDouble(),
      source: json['source'] as String?,
    );
  }
}
