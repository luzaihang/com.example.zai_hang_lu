class PersonalFolderFromMap {
  String folderName;
  String folderPassword;
  String folderId;
  String fondNameList;
  String creationTime;
  List<String> images;
  int folderIntegral;

  PersonalFolderFromMap({
    required this.folderName,
    required this.folderPassword,
    required this.folderId,
    required this.fondNameList,
    required this.creationTime,
    required this.images,
    required this.folderIntegral,
  });

  // 工厂方法创建一个Map
  factory PersonalFolderFromMap.fromMap(Map<String, dynamic> data) {
    return PersonalFolderFromMap(
      folderName: data['folderName'] as String,
      folderPassword: data['folderPassword'] as String,
      folderId: data['folderId'] as String,
      fondNameList: data['fondNameList'] as String,
      creationTime: data['creationTime'] as String,
      images: List<String>.from(data['images'] ?? []),
      folderIntegral: data['folderIntegral'] as int,
    );
  }

  // 将Folder对象转化为Map
  Map<String, dynamic> toMap() {
    return {
      'folderName': folderName,
      'folderPassword': folderPassword,
      'folderId': folderId,
      'fondNameList': fondNameList,
      'creationTime': creationTime,
      'images': images,
      'folderIntegral': folderIntegral,
    };
  }

  // 添加 copyWith 方法
  PersonalFolderFromMap copyWith({
    String? folderName,
    String? folderPassword,
    String? folderId,
    String? fondNameList,
    String? creationTime,
    List<String>? images,
    int? folderIntegral,
  }) {
    return PersonalFolderFromMap(
      folderName: folderName ?? this.folderName,
      folderPassword: folderPassword ?? this.folderPassword,
      folderId: folderId ?? this.folderId,
      fondNameList: fondNameList ?? this.fondNameList,
      creationTime: creationTime ?? this.creationTime,
      images: images ?? this.images,
      folderIntegral: folderIntegral ?? this.folderIntegral,
    );
  }
}
