import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/global_component/auth_manager.dart';
import 'package:ci_dong/tencent/tencent_cloud_txt_download.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ci_dong/app_data/show_custom_snackBar.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/global_component/show_custom_dialog.dart';
import 'package:ci_dong/tencent/tencent_upload_download.dart';

import '../global_component/user_name_modified_dialog.dart';

class PanelWidget extends StatefulWidget {
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
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    bool? res = await showCustomDialog(context, "是否同意进入到相册选择图片");
    if (res != true) return;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      String? getImage = image?.path;
      if (getImage == null) return;

      if (mounted) showCustomSnackBar(context, "正在上传 ，请稍候");
      bool res = await TencentUpLoadAndDownload.avatarUpLoad(getImage);
      if (!res) if (mounted) showCustomSnackBar(context, "头像更换失败，稍后再试");
      // 清除缓存
      CachedNetworkImage.evictFromCache(UserInfoConfig.userAvatar);
      setState(() {});
    } catch (e) {
      if (mounted) showCustomSnackBar(context, "图片选择失败");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.isVisible)
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.black.withOpacity(0.2),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          left: widget.isVisible ? 0 : -widget.panelWidth,
          top: 0,
          bottom: 0,
          child: Container(
            width: widget.panelWidth,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    UserInfoConfig.userName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildListTile(
                  icon: Icons.edit,
                  text: '修改昵称',
                  onTap: () async {
                    String? newName = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return ModifiedNameDialog();
                      },
                    );
                    if (newName != null && newName.isNotEmpty) {
                      String result =
                          await TencentCloudTxtDownload.userInfoTxt();

                      String modifiedData = result.replaceAll(
                        'userName=${UserInfoConfig.userName}',
                        'userName=$newName',
                      );

                      if (mounted) {
                        bool? res = await TencentUpLoadAndDownload.userUpLoad(
                          context,
                          modifiedData,
                          modified: true,
                        );
                        if (res == true) {
                          UserInfoConfig.userName = newName;
                          await AuthManager.setUserName(newName);
                          setState(() {});
                        }
                      }
                    }
                  },
                ),
                _buildListTile(
                  icon: Icons.privacy_tip,
                  text: '隐私协议',
                  onTap: () {
                    // 处理隐私协议的点击事件
                  },
                ),
                _buildListTile(
                  icon: Icons.contact_phone,
                  text: '联系客服',
                  onTap: () {
                    // 处理联系客服的点击事件
                  },
                ),
                _buildListTile(
                  icon: Icons.login_outlined,
                  text: '退出登录',
                  onTap: () async {
                    // 只清除登录状态和时间戳，保留昵称、头像和唯一ID
                    await AuthManager.clearLoginStatus(clearAll: false);

                    if (mounted) {
                      Navigator.pushReplacementNamed(context, "/loginScreen");
                    }
                  },
                ),
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        height: 40,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "次动 app v 1.0.0",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            backgroundImage: UserInfoConfig.userAvatar.isNotEmpty
                ? CachedNetworkImageProvider(
                    UserInfoConfig.userAvatar,
                  )
                : null,
            backgroundColor:
                UserInfoConfig.userAvatar.isEmpty ? Colors.blueGrey : null,
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
              onTap: () => _pickImages(),
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
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              width: 0.1,
              color: Colors.blueGrey.withOpacity(0.7),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.blueGrey,
              size: 16,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
