class UserInfoFromMap {
  String userName;
  String uniqueID;
  String userPassword;
  String userAvatar;

  UserInfoFromMap({
    required this.userName,
    required this.uniqueID,
    required this.userPassword,
    required this.userAvatar,
  });

  // 工厂构造函数，用于从Map创建对象
  factory UserInfoFromMap.fromMap(Map<String, dynamic> map) {
    return UserInfoFromMap(
      userName: map['userName'] ?? "",
      uniqueID: map['uniqueID'] ?? "",
      userPassword: map['userPassword'] ?? "",
      userAvatar: map['userAvatar'] ?? "",
    );
  }

  // 转换为Map的方法，如果需要转换回Map，可以使用这个方法
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'uniqueID': uniqueID,
      'userPassword': userPassword,
      'userAvatar': userAvatar,
    };
  }
}