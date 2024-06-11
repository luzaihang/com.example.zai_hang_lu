import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ci_dong/app_data/show_custom_snackBar.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/global_component/show_custom_dialog.dart';
import 'package:ci_dong/tencent/tencent_cloud_acquiesce_data.dart';
import 'package:ci_dong/tencent/tencent_upload_download.dart';

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
      UserInfoConfig.userAvatar =
          "https://${TencentCloudAcquiesceData.avatarAndPost}.cos.${TencentCloudAcquiesceData.region}.myqcloud.com/${UserInfoConfig.userID}/userAvatar.png";
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
                    '意见反馈',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                  onTap: () {
                    // 在这里处理修改密码的点击事件
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.blueGrey),
                  title: const Text(
                    '隐私协议',
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
                ListTile(
                  leading:
                      const Icon(Icons.login_outlined, color: Colors.blueGrey),
                  title: const Text(
                    '退出登录',
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
