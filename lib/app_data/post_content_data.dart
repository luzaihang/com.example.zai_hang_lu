class PostContentData {
  static String postID = ""; //帖子ID

  /// 记录上传到的bucket位置，因为是不同的bucket，所以要记录正确位置，才能准确展示图片
  List<String> uploadedImagePaths = [];

  /// 添加新的cosPath到list
  void addToPostImagePaths(String cosPath) {
    uploadedImagePaths.add(cosPath);
  }

  /// 在发帖前清空list
  void prepareForNewPost() {
    uploadedImagePaths.clear();
  }
}

///这是要上传到服务端的帖子内容
class PostDetails {
  String userName;
  String userAvatar;
  String location;
  String postContent;
  List<String> postImages;
  String postCreationTime;

  // 构造函数
  PostDetails({
    required this.userName,
    required this.userAvatar,
    required this.location,
    required this.postContent,
    required this.postImages,
    required this.postCreationTime,
  });

  // 从传入的Map中初始化值
  void fromMap(Map<String, dynamic> map) {
    userName = map['userName'];
    userAvatar = map['userAvatar'];
    location = map['location'];
    postContent = map['postContent'];
    postImages = List<String>.from(map['postImages']);
    postCreationTime = map['postCreationTime'];
  }

  // 将实例转换为Map
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
