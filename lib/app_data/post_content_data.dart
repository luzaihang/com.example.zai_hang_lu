class PostContentConfig {
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
