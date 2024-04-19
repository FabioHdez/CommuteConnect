class UserModel {
  final String username;
  final String bio;
  final String profileImageUrl;

  UserModel({required this.username, required this.bio, required this.profileImageUrl});

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      username: map['username'] as String? ?? 'No username',
      bio: map['bio'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String? ?? 'https://images-ng.pixai.art/images/orig/1b280ade-efbc-4ed3-a69f-14536357122e',
    );
  }
}

