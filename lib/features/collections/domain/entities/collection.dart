import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  const Collection({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, name, createdAt];
}
