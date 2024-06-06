class PostDetails {
  final String userName;
  final String userAvatar;
  final String location;
  final String postContent;
  final List<String> postImages;
  final String postCreationTime;

  PostDetails({
    required this.userName,
    required this.userAvatar,
    required this.location,
    required this.postContent,
    required this.postImages,
    required this.postCreationTime,
  });

  // 从Map创建PostDetails对象
  factory PostDetails.fromMap(Map<String, dynamic> map) {
    return PostDetails(
      userName: map['userName'],
      userAvatar: map['userAvatar'],
      location: map['location'],
      postContent: map['postContent'],
      postImages: List<String>.from(map['postImages']),
      postCreationTime: map['postCreationTime'],
    );
  }

  // 将PostDetails对象转为Map
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userAvatar': userAvatar,
      'location': location,
      'postContent': postContent,
      'postImages': postImages,
      'postCreationTime': postCreationTime,
    };
  }
}