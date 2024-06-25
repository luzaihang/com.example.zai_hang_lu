import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/default_config/app_system_chrome_config.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/factory_list/personal_folder_from_map.dart';
import 'package:ci_dong/factory_list/post_detail_from_json.dart';
import 'package:ci_dong/global_component/route_generator.dart';
import 'package:ci_dong/my_page/personal_tab_bar.dart';
import 'package:ci_dong/my_page/personal_top_section.dart';
import 'package:ci_dong/my_page/personal_page_dialogs.dart';
import 'package:ci_dong/provider/personal_name_notifier.dart';
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
  late final PersonalPageNotifier _personalPageReadNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        _personalPageReadNotifier.setSelectedIndex(_tabController.index);
      });

    _postScrollController = ScrollController();

    avatarUrl =
        "${DefaultConfig.personalInfoPrefix}/${widget.userId}/userAvatar.png";
    _personalPageReadNotifier = context.read<PersonalPageNotifier>();
    _personalPageReadNotifier.getPostData(widget.userId);
    _personalPageReadNotifier.personalBanner(widget.userId);
    _personalPageReadNotifier.personalFolder(widget.userId);
  }

  @override
  void dispose() {
    _postScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  late OverlayEntry _overlayEntry;

  void _showPreview(BuildContext context, String url) {
    _overlayEntry = _createOverlayEntry(context, url);
    Overlay.of(context).insert(_overlayEntry);
  }

  void _hidePreview() {
    if (_overlayEntry.mounted) {
      _overlayEntry.remove();
    }
  }

  OverlayEntry _createOverlayEntry(BuildContext context, String url) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: Material(
          color: Colors.black54,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: url,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200.0,
          child: PersonalTopSection(
            avatarUrl: avatarUrl,
            userId: widget.userId,
            onBackButtonPressed: () => Navigator.pop(context),
            onChatButtonPressed: () {
              String name = context
                  .read<PersonalNameNotifier>()
                  .getCachedName(widget.userId);
              Navigator.pushNamed(
                context,
                "/chatDetailPage",
                arguments: ChatDetailPageArguments(
                  taUserName: name,
                  taUserAvatar: avatarUrl,
                  taUserID: widget.userId,
                ),
              );
            },
          ),
        ),
        PersonalTabBar(tabController: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGalleryTab(),
              _buildPostTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryTab() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 1,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            _buildBannerSection(context),
            _buildAlbumSection(context),
          ],
        );
      },
    );
  }

  Widget _buildBannerSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 230,
      child: Consumer<PersonalPageNotifier>(
        builder: (BuildContext context, provider, Widget? child) {
          return _buildBannerImages(provider);
        },
      ),
    );
  }

  Widget _buildBannerImages(PersonalPageNotifier provider) {
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
          child: provider.personalBannerImages.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.personalBannerImages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildBannerImageItem(
                        provider.personalBannerImages, index);
                  },
                )
              : _buildEmptyBannerPlaceholder(),
        ),
      ],
    );
  }

  Widget _buildBannerImageItem(List<String> images, int index) {
    return Container(
      width: 200,
      height: 200,
      margin: EdgeInsets.fromLTRB(
          index == 0 ? 20 : 10, 0, index == (images.length - 1) ? 20 : 0, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/galleryPhotoView",
              arguments: GalleryPhotoViewArguments(
                imageUrls: images,
                initialIndex: index,
              ),
            );
          },
          child: CachedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBannerPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF052D84),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Align(
        child: Image.asset(
          "assets/banner_not_img_icon.png",
          width: 90,
          height: 90,
        ),
      ),
    );
  }

  Widget _buildAlbumSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlbumHeader(context),
          const SizedBox(height: 10),
          _buildAlbumGrid(),
        ],
      ),
    );
  }

  Widget _buildAlbumHeader(BuildContext context) {
    return Consumer<PersonalPageNotifier>(
      builder: (context, provider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "TA的图册",
                  style: TextStyle(
                    color: Color(0xFF052D84),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    "（长按文件夹可预览）",
                    style: TextStyle(
                      color: Color(0xFF052D84),
                      fontSize: 11,
                    ),
                  ),
                ),
                Image.asset(
                  "assets/question_mark_icon.png",
                  width: 14,
                  height: 14,
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                PersonalFolderFromMap folderFromMap =
                    await showFolderAddDialog(context);
                if (folderFromMap.folderName.isNotEmpty) {
                  if (mounted) {
                    _personalPageReadNotifier.personalPageImageFile(
                        context, folderFromMap);
                  }
                }
              },
              child: Image.asset(
                "assets/add_icon.png",
                width: 20,
                height: 20,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlbumGrid() {
    return SingleChildScrollView(
      child: Consumer<PersonalPageNotifier>(
        builder: (context, provider, _) {
          return provider.folderList.isNotEmpty
              ? GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: provider.folderList.length,
                  itemBuilder: (context, index) {
                    return _buildFolderItem(provider.folderList[index]);
                  },
                )
              : _buildEmptyFolderPlaceholder();
        },
      ),
    );
  }

  Widget _buildFolderItem(PersonalFolderFromMap item) {
    return Column(
      children: [
        GestureDetector(
          onLongPress: () => _showPreview(context, item.images.first),
          onLongPressUp: _hidePreview,
          onTap: item.fondNameList.contains(UserInfoConfig.uniqueID)
              ? () {
                  if (context.mounted) {
                    Navigator.pushNamed(
                      context,
                      "/galleryPhotoView",
                      arguments: GalleryPhotoViewArguments(
                        imageUrls: item.images,
                        initialIndex: 0,
                      ),
                    );
                  }
                }
              : () async {
                  bool? res = await showActionDialog(context);
                  if (res == true) {
                    if (context.mounted) {
                      context
                          .read<PersonalPageNotifier>()
                          .updateFolderPermission(
                            item,
                            widget.userId,
                          );
                    }
                    if (context.mounted) {
                      Navigator.pushNamed(
                        context,
                        "/galleryPhotoView",
                        arguments: GalleryPhotoViewArguments(
                          imageUrls: item.images,
                          initialIndex: 0,
                        ),
                      );
                    }
                  }
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
          item.folderName,
          style: const TextStyle(
            color: Color(0xFF052D84),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFolderPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF052D84),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Align(
        child: Image.asset(
          "assets/banner_not_img_icon.png",
          width: 90,
          height: 90,
        ),
      ),
    );
  }

  Widget _buildPostTab() {
    return Consumer<PersonalPageNotifier>(
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
    );
  }
}
