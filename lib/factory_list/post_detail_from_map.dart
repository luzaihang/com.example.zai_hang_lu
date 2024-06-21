///这是要上传到服务端的帖子内容
class PostDetailFromMap {
  String userName;
  String userID;
  String userAvatar;
  String location;
  String postContent;
  List<String> postImages;
  String postCreationTime;
  String upvote; //点赞的人,包含了所以点赞人的userid
  String postId; //帖子id

  // 构造函数
  PostDetailFromMap({
    required this.userName,
    required this.userID,
    required this.userAvatar,
    required this.location,
    required this.postContent,
    required this.postImages,
    required this.postCreationTime,
    required this.upvote,
    required this.postId,
  });

  // 从传入的Map中初始化值
  void fromMap(Map<String, dynamic> map) {
    userName = map['userName'];
    userID = map['userID'];
    userAvatar = map['userAvatar'];
    location = map['location'];
    postContent = map['postContent'];
    postImages = List<String>.from(map['postImages']);
    postCreationTime = map['postCreationTime'];
    upvote = map['upvote'];
    postId = map['postId'];
  }

  // 将实例转换为Map
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userID': userID,
      'userAvatar': userAvatar,
      'location': location,
      'postContent': postContent,
      'postImages': postImages,
      'postCreationTime': postCreationTime,
      'upvote': upvote,
      'postId': postId,
    };
  }
}
