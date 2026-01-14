import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String id;
  final String text;
  final String author;
  final String category;
  final List<String>? tags;
  final double? popularity;
  final String? source;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    this.tags,
    this.popularity,
    this.source,
  });

  @override
  List<Object?> get props => [
    id,
    text,
    author,
    category,
    tags,
    popularity,
    source,
  ];
}
