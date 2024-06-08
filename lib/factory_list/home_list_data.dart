///首页列表数据类
class UserPost {
  final String userName;
  final String? userID;
  final String userAvatar;
  final String location;
  final String postContent;
  final List<String> postImages;
  final DateTime postCreationTime;

  UserPost({
    required this.userName,
    required this.userID,
    required this.userAvatar,
    required this.location,
    required this.postContent,
    required this.postImages,
    required this.postCreationTime,
  });

  factory UserPost.fromJson(Map<String, dynamic> json) {
    return UserPost(
      userName: json['userName'],
      userID: json['userID'] ?? "",
      userAvatar: json['userAvatar'],
      location: json['location'],
      postContent: json['postContent'],
      postImages: List<String>.from(json['postImages']),
      postCreationTime: DateTime.parse(json['postCreationTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userID': userID,
      'userAvatar': userAvatar,
      'location': location,
      'postContent': postContent,
      'postImages': postImages,
      'postCreationTime': postCreationTime.toIso8601String(),
    };
  }
}