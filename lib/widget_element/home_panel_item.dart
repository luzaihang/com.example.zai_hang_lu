import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';

class PanelWidget extends StatelessWidget {
  final bool isVisible;
  final double panelWidth;
  final VoidCallback onClose;

  const PanelWidget({
    Key? key,
    required this.isVisible,
    required this.panelWidth,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isVisible)
          GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.black.withOpacity(0.2),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          left: isVisible ? 0 : -panelWidth,
          top: 0,
          bottom: 0,
          child: Container(
            width: panelWidth,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: UserInfoConfig.userAvatar.isNotEmpty
                            ? CachedNetworkImageProvider(
                                UserInfoConfig.userAvatar)
                            : null,
                        backgroundColor: UserInfoConfig.userAvatar.isEmpty
                            ? Colors.blueGrey
                            : null,
                        radius: 40.0,
                        child: UserInfoConfig.userAvatar.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 50.0,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // 在这里处理头像点击事件，比如打开图库选择新头像
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 15,
                            child: Icon(
                              Icons.camera_alt,
                              size: 15,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blueGrey),
                  title: const Text(
                    '修改昵称',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                  onTap: () {
                    // 在这里处理修改昵称的点击事件
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.blueGrey),
                  title: const Text(
                    '修改密码',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                  onTap: () {
                    // 在这里处理修改密码的点击事件
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.feedback, color: Colors.blueGrey),
                  title: const Text(
                    '用户反馈',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                  onTap: () {
                    // 在这里处理修改密码的点击事件
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.contact_phone, color: Colors.blueGrey),
                  title: const Text(
                    '联系客服',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                  onTap: () {
                    // 在这里处理联系客服的点击事件
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
