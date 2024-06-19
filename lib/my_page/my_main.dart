import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/provider/my_page_notifier.dart';
import 'package:ci_dong/provider/visibility_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class MyMain extends StatefulWidget {
  const MyMain({super.key});

  @override
  State<MyMain> createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyPageNotifier()),
      ],
      child: ListView.builder(
        controller: _scrollController,
        itemCount: 1,
        itemBuilder: (context, index) {
          MyPageNotifier myPageNotifier = context.read<MyPageNotifier>();
          myPageNotifier.bannerImgFun();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 45, 0, 20),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "个人中心",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF052D84),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Consumer<MyPageNotifier>(
                builder: (BuildContext context, provider, Widget? child) {
                  return provider.bannerImgList.isNotEmpty
                      ? SizedBox(
                          width: double.infinity,
                          height: 440,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children:
                                provider.bannerImgList.asMap().keys.map((e) {
                              return Container(
                                margin: EdgeInsets.only(
                                    right: 20, left: e == 0 ? 20 : 0),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(14)),
                                  child: CachedNetworkImage(
                                    height: 440,
                                    width: screenWidth - 70,
                                    imageUrl: provider.bannerImgList[e],
                                    placeholder: (context, url) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white.withOpacity(0.7),
                                          backgroundColor:
                                              const Color(0xFF052D84),
                                          strokeWidth: 2.5,
                                          strokeCap: StrokeCap.round,
                                        ),
                                      );
                                    },
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }).toList(),
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
              ),
              GestureDetector(
                onTap: () {
                  myPageNotifier.bannerImageFile(context);
                },
                child: Container(
                  height: 80,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Consumer<MyPageNotifier>(
                        builder:
                            (BuildContext context, provider, Widget? child) {
                          return Stack(
                            alignment: Alignment.center, // 确保子元素在Stack的中心
                            children: [
                              CircularProgressIndicator(
                                value: (provider.bannerImgList.length / 5),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF052D84),
                                ),
                                backgroundColor:
                                    const Color(0xFF052D84).withOpacity(0.2),
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
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "设置墙贴",
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
                            "图库选择靓照吧～",
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
                      "assets/chat_icon.png",
                      height: 26,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
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
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "快快畅所欲言吧～",
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
                height: 110,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                decoration: const BoxDecoration(
                  // color: const Color(0xFF052D84), //0xFF0645B6 0xFF000822
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/photo_album_icon.png",
                      width: 70,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "相册集",
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
                          "免费有 1G 存储空间",
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
              const SizedBox(height: 3),
              Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  // color: const Color(0xFF052D84), //0xFF0645B6 0xFF000822
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "查看全部",
                  style: TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.bold,
                    color: Color(0xFF1770D4),
                  ),
                ),
              ),
              const SizedBox(height: 35),
            ],
          );
        },
      ),
    );
  }
}
