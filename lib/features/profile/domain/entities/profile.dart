import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String? fullName;
  final String? avatarUrl;

  const Profile({required this.id, this.fullName, this.avatarUrl});

  @override
  List<Object?> get props => [id, fullName, avatarUrl];
}
