class UserInfoFromJson {
  String userName;
  String uniqueID;
  String userPassword;
  String userAvatar;

  UserInfoFromJson({
    required this.userName,
    required this.uniqueID,
    required this.userPassword,
    required this.userAvatar,
  });

  // 将对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'uniqueID': uniqueID,
      'userPassword': userPassword,
      'userAvatar': userAvatar,
    };
  }

  // 从 JSON 创建对象的工厂构造函数
  factory UserInfoFromJson.fromJson(Map<String, dynamic> json) {
    return UserInfoFromJson(
      userName: json['userName'],
      uniqueID: json['uniqueID'],
      userPassword: json['userPassword'],
      userAvatar: json['userAvatar'],
    );
  }

  // 添加 `copyWith` 方法,用于修改某个值,可空
  UserInfoFromJson copyWith({
    String? userName,
    String? uniqueID,
    String? userPassword,
    String? userAvatar,
  }) {
    return UserInfoFromJson(
      userName: userName ?? this.userName,
      uniqueID: uniqueID ?? this.uniqueID,
      userPassword: userPassword ?? this.userPassword,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }
}
