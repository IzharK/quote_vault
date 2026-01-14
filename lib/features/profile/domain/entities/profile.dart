import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String? fullName;
  final String? avatarUrl;

  const Profile({required this.id, this.fullName, this.avatarUrl});

  Profile copyWith({String? id, String? fullName, String? avatarUrl}) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, fullName, avatarUrl];
}
