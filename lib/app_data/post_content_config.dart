class PostContentConfig {

  /// 记录上传到的bucket位置，因为是不同的bucket，所以要记录正确位置，才能准确展示图片
  List<String> uploadedImagePaths = [];

  /// 个人文件夹图片的path
  List<String> personalFolderUploadImagePaths = [];

  /// 添加新的cosPath到list
  void addToPostImagePaths(String cosPath) {
    uploadedImagePaths.add(cosPath);
  }

  /// 在发帖前清空list
  void prepareForNewPost() {
    uploadedImagePaths.clear();
  }

  /// 个人文件夹图片的path，准备上传txt的path
  void personalFolderImagePaths(String cosPath) {
    personalFolderUploadImagePaths.add(cosPath);
  }

  /// 在创建前清空list
  void cleanFolderImages() {
    personalFolderUploadImagePaths.clear();
  }
}
