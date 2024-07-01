import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/global_component/route_generator.dart';
import 'package:ci_dong/provider/my_page_notifier.dart';
import 'package:ci_dong/provider/upvote_notifier.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:ci_dong/routes_widgets/vip_page.dart';
import 'package:ci_dong/widget_element/avatar_widget_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class MyMain extends StatefulWidget {
  const MyMain({super.key});

  @override
  State<MyMain> createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {
  late ScrollController _scrollController;
  late VisibilityNotifier _visibilityNotifier;
  late MyPageNotifier _myReadNotifier;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _myReadNotifier = context.read<MyPageNotifier>();
    _visibilityNotifier = context.read<VisibilityNotifier>();
    _myReadNotifier.getBanner(); //获取banner图片list
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      controller: _scrollController,
      itemCount: 1,
      itemBuilder: (context, index) {
        return Column(
          children: [
            _buildHeader(context),
            _buildBannerList(screenWidth),
            _buildSettingImage(context),
            _buildChatHistoryTile(context),
            _buildVipTile(context),
            const SizedBox(height: 20),
            _buildAlbumTile(context),
            const SizedBox(height: 3),
            _buildViewAllTile(),
            const SizedBox(height: 35),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 45, 0, 20),
      child: Row(
        children: [
          ClipOval(
            child: GestureDetector(
              onTap: () {
                _myReadNotifier.myPageImageFile(context, true);
              },
              child: Consumer<MyPageNotifier>(
                builder: (context, notifier, child) {
                  return AvatarWidget(
                    userId: UserInfoConfig.uniqueID,
                    meNewAvatarUrl: notifier.newAvatarUrl,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              UserInfoConfig.userName,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF052D84),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerList(double screenWidth) {
    return Consumer<MyPageNotifier>(
      builder: (context, provider, child) {
        return provider.bannerImgList.isNotEmpty
            ? SizedBox(
                width: double.infinity,
                height: 440,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.bannerImgList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin:
                          EdgeInsets.only(right: 20, left: index == 0 ? 20 : 0),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(14)),
                        child: CachedNetworkImage(
                          height: 440,
                          width: screenWidth - 70,
                          imageUrl: provider.bannerImgList[index],
                          placeholder: (context, url) {
                            return const Center(
                              child: SpinKitFoldingCube(
                                color: Colors.white,
                                size: 20.0,
                                duration: Duration(milliseconds: 800),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              )
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 480,
                decoration: BoxDecoration(
                  color: const Color(0xFF052D84),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Align(
                  child: Image.asset(
                    "assets/banner_not_img_icon.png",
                    width: 128,
                    height: 128,
                  ),
                ),
              );
      },
    );
  }

  Widget _buildSettingImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _myReadNotifier.myPageImageFile(context, false);
      },
      child: Container(
        height: 80,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Consumer<MyPageNotifier>(
              builder: (context, provider, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: (provider.bannerImgList.length / 5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF052D84)),
                      backgroundColor: const Color(0xFF052D84).withOpacity(0.2),
                      strokeWidth: 4.0,
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      "${provider.bannerImgList.length}/5",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF052D84),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "设置墙照",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF052D84),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "图库选择靓照，给陌生人点赞吧～",
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

  Widget _buildChatHistoryTile(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/chatListPage'),
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
              "assets/chat_icon.png",
              height: 26,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "聊天记录",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF052D84),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "快快畅所欲言吧～",
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

  Widget _buildVipTile(BuildContext context) {
    return GestureDetector(
      // onTap: () => Navigator.pushNamed(context, '/vipPage'),
      onTap: ()=> showVipModal(context),
      child: Container(
        height: 80,
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
        child: Row(
          children: [
            Image.asset(
              "assets/chat_icon.png",
              height: 26,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "尊贵VIP",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF052D84),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "开启个人文件夹功能～",
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

  Widget _buildAlbumTile(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 110,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Image.asset(
                "assets/photo_album_icon.png",
                width: 70,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "个人主页",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF052D84),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "发布图片可赚取积分哟～",
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
      ],
    );
  }

  Widget _buildViewAllTile() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/personalPage",
          arguments: PersonalPageArguments(userId: UserInfoConfig.uniqueID),
        );
      },
      child: Container(
        height: 50,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        alignment: Alignment.center,
        child: const Text(
          "查看详情",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1770D4),
          ),
        ),
      ),
    );
  }
}
