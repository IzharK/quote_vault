import 'package:quote_vault/features/profile/domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({required super.id, super.fullName, super.avatarUrl});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'avatar_url': avatarUrl};
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      fullName: profile.fullName,
      avatarUrl: profile.avatarUrl,
    );
  }
}
