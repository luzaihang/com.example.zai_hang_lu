import 'dart:convert';

import 'package:ci_dong/app_data/app_encryption_helper.dart';
import 'package:ci_dong/app_data/show_custom_snackBar.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/user_info_from_json.dart';
import 'package:ci_dong/global_component/auth_manager.dart';
import 'package:ci_dong/global_component/user_name_modified_dialog.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:ci_dong/tencent/tencent_cloud_download.dart';
import 'package:ci_dong/tencent/tencent_cloud_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class SettingPageMain extends StatefulWidget {
  const SettingPageMain({super.key});

  @override
  State<SettingPageMain> createState() => _SettingPageMainState();
}

class _SettingPageMainState extends State<SettingPageMain> {
  late ScrollController _scrollController;
  late VisibilityNotifier _visibilityNotifier;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _visibilityNotifier = context.read<VisibilityNotifier>();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      _visibilityNotifier.updateVisibility(false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      _visibilityNotifier.updateVisibility(true);
    }
  }

  Future<void> _modifyUserName(BuildContext context) async {
    String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return ModifiedNameDialog();
      },
    );

    if (newName != null && newName.isNotEmpty) {
      String result = await TencentCloudTxtDownload.userInfoTxt();
      String decryptResult = EncryptionHelper.decrypt(result); // 解密
      List userinfoMaps = jsonDecode(decryptResult); //解码

      String userId = '';

      for (int i = 0; i < userinfoMaps.length; i++) {
        UserInfoFromJson infoItem = UserInfoFromJson.fromJson(userinfoMaps[i]);
        if (infoItem.userName == UserInfoConfig.userName) {
          userId = infoItem.uniqueID;
          UserInfoFromJson updatedInfoItem =
              infoItem.copyWith(userName: newName);
          userinfoMaps[i] = updatedInfoItem.toJson();
          break;
        }
      }
      //().d(userinfoMaps);

      if (mounted) {
        if (mounted) showCustomSnackBar(context, "正在更新昵称...");
        bool? res = await userUpLoad(
          context,
          jsonEncode(userinfoMaps), //编码上传
          modified: true,
        );
        if (res == true) {
          bool? boo = await personalNameUpload(userId, newName);
          if (boo == true) {
            UserInfoConfig.userName = newName;
            await AuthManager.setUserName(newName);
          } else {
            if (mounted) showCustomSnackBar(context, "昵称修改失败，稍候再试");
          }
        } else {
          if (mounted) showCustomSnackBar(context, "昵称修改失败，稍候再试");
        }
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    // 只清除登录状态和时间戳，保留昵称、头像和唯一ID
    await AuthManager.clearLoginStatus(clearAll: false);

    if (mounted) {
      Navigator.pushReplacementNamed(context, "/loginScreen");
    }
  }

  Widget _buildSettingItem({
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              height: 26,
              width: 26,
              color: const Color(0xFF052D84),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF052D84),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF052D84).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 1,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 45, 0, 20),
              alignment: Alignment.centerLeft,
              child: const Text(
                "设置",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF052D84),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSettingItem(
              iconPath: "assets/edit_icon.png",
              title: "修改昵称",
              subtitle: "设置独一无二的昵称吧～",
              onTap: () => _modifyUserName(context),
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              iconPath: "assets/privacy_policy_icon.png",
              title: "隐私政策与用户协议",
              subtitle: "APP 使用政策与权限调用协议",
              onTap: () {},
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              iconPath: "assets/third_party_icon.png",
              title: "第三方信息说明",
              subtitle: "APP 内部使用的第三方服务",
              onTap: () {},
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              iconPath: "assets/customer_service_icon.png",
              title: "客服反馈",
              subtitle: "在线留言，第一时间回复您的问题",
              onTap: () {},
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              iconPath: "assets/login_out_icon.png",
              title: "退出登录",
              subtitle: "退出当前用户/切换其他账号",
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
