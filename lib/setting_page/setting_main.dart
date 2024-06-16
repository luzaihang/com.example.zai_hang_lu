import 'package:ci_dong/provider/visibility_notifier.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final visibilityNotifier =
        Provider.of<VisibilityNotifier>(context, listen: false);

    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      visibilityNotifier.updateVisibility(false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      visibilityNotifier.updateVisibility(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return ListView.builder(
        controller: _scrollController,
        itemCount: 1,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  45,
                  0,
                  20,
                ),
                child: Container(
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
              ),
              Container(
                height: 80,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    // color: const Color(0xFF052D84), //0xFF0645B6 0xFF000822
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/edit_icon.png",
                      height: 26,
                      width: 26,
                      color: const Color(0xFF052D84),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "修改昵称",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF052D84),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "设置独一无二的昵称吧～",
                          style: TextStyle(
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                            color: const Color(0xFF052D84).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 80,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    // color: const Color(0xFF052D84), //0xFF0645B6 0xFF000822
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/privacy_policy_icon.png",
                      height: 26,
                      width: 26,
                      color: const Color(0xFF052D84),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "隐私政策与用户协议",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF052D84),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "APP 使用政策与权限调用协议",
                          style: TextStyle(
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                            color: const Color(0xFF052D84).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 80,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  // color: const Color(0xFF052D84), //0xFF0645B6 0xFF000822
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/login_out_icon.png",
                      height: 26,
                      width: 26,
                      color: const Color(0xFF052D84),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "退出登录",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF052D84),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "退出当前用户/切换其他账号",
                          style: TextStyle(
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                            color: const Color(0xFF052D84).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        });
  }
}
