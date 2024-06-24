import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/default_config/app_system_chrome_config.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/factory_list/post_detail_from_json.dart';
import 'package:ci_dong/global_component/route_generator.dart';
import 'package:ci_dong/provider/personal_page_notifier.dart';
import 'package:ci_dong/widget_element/post_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalPage extends StatelessWidget {
  final String userId;

  ///个人主页
  const PersonalPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    systemChromeColor(Colors.transparent, Brightness.dark);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PersonalPageNotifier()),
        ],
        child: PersonalPageBody(userId: userId),
      ),
    );
  }
}

class PersonalPageBody extends StatefulWidget {
  final String userId;

  const PersonalPageBody({super.key, required this.userId});

  @override
  PersonalPageBodyState createState() => PersonalPageBodyState();
}

class PersonalPageBodyState extends State<PersonalPageBody>
    with SingleTickerProviderStateMixin {
  late final ScrollController _postScrollController;
  late final TabController _tabController;
  late final String avatarUrl;
  late final PersonalPageNotifier _personalPageNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        _personalPageNotifier.setSelectedIndex(_tabController.index);
      });

    _postScrollController = ScrollController();

    avatarUrl =
        "${DefaultConfig.personalInfoPrefix}/${widget.userId}/userAvatar.png";
    _personalPageNotifier = context.read<PersonalPageNotifier>();
    _personalPageNotifier.getPostData(widget.userId);
    _personalPageNotifier.personalBanner(widget.userId);
  }

  @override
  void dispose() {
    _postScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  TextStyle _getTabTextStyle(BuildContext context, int index) {
    final selectedIndex = context.watch<PersonalPageNotifier>().selectedIndex;
    return TextStyle(
      fontSize: selectedIndex == index ? 18 : 16,
      fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
      color: const Color(0xFF052D84),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200.0,
          child: _buildTopSection(),
        ),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _buildTabViews(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSection() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            "$avatarUrl?${DateTime.now().millisecondsSinceEpoch}",
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          child: _buildAvatarAndInfo(),
        ),
        Positioned(
          top: 45,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              "返回",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarAndInfo() {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.network(
                "$avatarUrl?${DateTime.now().millisecondsSinceEpoch}",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "暗夜公爵",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    "assets/redact_icon.png",
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const SizedBox(
                width: 200,
                child: Text(
                  "点击设置个性签名吧～",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 150,
          height: 40,
          child: TabBar(
            controller: _tabController,
            indicator: CustomTabIndicator(),
            tabs: [
              Consumer<PersonalPageNotifier>(
                builder: (context, provider, _) => Text(
                  "图集",
                  style: _getTabTextStyle(context, 0),
                ),
              ),
              Consumer<PersonalPageNotifier>(
                builder: (context, provider, _) => Text(
                  "帖子",
                  style: _getTabTextStyle(context, 1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTabViews() {
    return [
      ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 230,
                child: Consumer<PersonalPageNotifier>(
                  builder: (BuildContext context, provider, Widget? child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "TA的墙照",
                            style: TextStyle(
                              color: Color(0xFF052D84),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.personalBannerImages.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                width: 200,
                                height: 200,
                                margin: EdgeInsets.fromLTRB(
                                  index == 0 ? 20 : 10,
                                  0,
                                  index ==
                                          (provider
                                                  .personalBannerImages.length -
                                              1)
                                      ? 20
                                      : 0,
                                  0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        "/galleryPhotoView",
                                        arguments: GalleryPhotoViewArguments(
                                          imageUrls:
                                              provider.personalBannerImages,
                                          initialIndex: index,
                                          postId: "",
                                        ),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          provider.personalBannerImages[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text(
                              "TA的图册",
                              style: TextStyle(
                                color: Color(0xFF052D84),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "（长按文件夹可预览）",
                              style: TextStyle(
                                color: Color(0xFF052D84),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Image.asset(
                            "assets/add_icon.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        // 非常重要，确保GridView的高度根据其内容来确定
                        physics: const NeverScrollableScrollPhysics(),
                        // 禁用GridView的滚动，使用SingleChildScrollView的滚动
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 每行3个图标
                          crossAxisSpacing: 10.0, // 设置列间距
                          mainAxisSpacing: 10.0, // 设置行间距
                        ),
                        itemCount: 10,
                        // 测试数据，根据实际数量更改
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // 添加点击事件的回调
                                },
                                child: Align(
                                  child: Image.asset(
                                    "assets/folder_icon.png",
                                    width: 90,
                                    height: 90,
                                  ),
                                ),
                              ),
                              Text(
                                "文件夹命名$index",
                                style: const TextStyle(
                                  color: Color(0xFF052D84),
                                  fontSize: 12,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      ///帖子tab
      Consumer<PersonalPageNotifier>(
        builder: (BuildContext context, provider, Widget? child) {
          double screenWidth = MediaQuery.of(context).size.width;
          return provider.personalPostList.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  controller: _postScrollController,
                  itemCount: provider.personalPostList.length,
                  itemBuilder: (BuildContext context, int index) {
                    PostDetailFormJson item = provider.personalPostList[index];
                    return PostListItem(
                      item: item,
                      screenWidth: screenWidth,
                      index: index,
                    );
                  },
                )
              : Center(
                  child: Image.asset(
                    "assets/not_post_icon.png",
                    width: 80,
                    height: 80,
                    color: const Color(0xFF052D84),
                  ),
                );
        },
      )
    ];
  }
}

class CustomTabIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _CustomPainter(this, onChanged!);
}

class _CustomPainter extends BoxPainter {
  static const double _indicatorHeight = 3.0;
  static const double _indicatorWidth = 20.0;
  static const Color _indicatorColor = Color(0xFF052D84);
  static const Radius _indicatorRadius = Radius.circular(4.0);

  _CustomPainter(this.decoration, VoidCallback onChanged) : super(onChanged);

  final CustomTabIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()..color = _indicatorColor;
    final double startX =
        offset.dx + (configuration.size!.width - _indicatorWidth) / 2;
    final double endX =
        offset.dx + (configuration.size!.width + _indicatorWidth) / 2;
    final double bottomY = configuration.size!.height - _indicatorHeight;
    final double topY = configuration.size!.height;
    canvas.drawRRect(
      RRect.fromLTRBR(startX, bottomY, endX, topY, _indicatorRadius),
      paint,
    );
  }
}
