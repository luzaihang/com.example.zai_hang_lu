///首页列表数据类
class PostDetailFormJson {
  final String userName;
  final String? userID;
  final String userAvatar;
  final String location;
  final String postContent;
  final List<String> postImages;
  final DateTime postCreationTime;
  final String? upvote; //点赞的人,包含了所以点赞人的userid

  PostDetailFormJson({
    required this.userName,
    required this.userID,
    required this.userAvatar,
    required this.location,
    required this.postContent,
    required this.postImages,
    required this.postCreationTime,
    required this.upvote,
  });

  factory PostDetailFormJson.fromJson(Map<String, dynamic> json) {
    return PostDetailFormJson(
      userName: json['userName'],
      userID: json['userID'] ?? '',
      userAvatar: json['userAvatar'],
      location: json['location'],
      postContent: json['postContent'],
      postImages: List<String>.from(json['postImages']),
      postCreationTime: DateTime.parse(json['postCreationTime']),
      upvote: json['upvote'] ?? '',
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
      'upvote': upvote,
    };
  }
}
