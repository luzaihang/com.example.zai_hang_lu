import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/factory_list/post_detail_from_json.dart';
import 'package:ci_dong/global_component/route_generator.dart';
import 'package:ci_dong/provider/personal_name_notifier.dart';
import 'package:ci_dong/provider/post_page_notifier.dart';
import 'package:ci_dong/provider/upvote_notifier.dart';
import 'package:ci_dong/widget_element/avatar_widget_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data/format_date_time.dart';

class PostListItem extends StatefulWidget {
  final PostDetailFormJson item;
  final double screenWidth;
  final int index;

  const PostListItem(
      {required this.item,
      required this.screenWidth,
      required this.index,
      Key? key})
      : super(key: key);

  @override
  State<PostListItem> createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  @override
  void initState() {
    context
        .read<PersonalNameNotifier>()
        .fetchAndCacheUserName(widget.item.userID ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 计算 | 在字符串中出现的次数,因为是用 (|userid) 来区分的，知道这个的次数就可以知道多少人点赞
    int count = '|'.allMatches(widget.item.upvote ?? "").length;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, widget.index == 0 ? 15 : 0, 20, 0),
          child: Row(
            children: [
              AvatarWidget(userId: widget.item.userID ?? ""),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<PersonalNameNotifier>(
                      builder: (BuildContext context, provider, Widget? child) {
                        final name =
                            provider.getCachedName(widget.item.userID ?? "");
                        return Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF052D84),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDateTimeToMinutes(widget.item.postCreationTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF052D84).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Consumer2<PostPageNotifier, UpvoteNotifier>(
                builder: (BuildContext context, pageNotifier, upvoteNotifier,
                    Widget? child) {
                  return GestureDetector(
                    onTap: () async {
                      PostDetailFormJson result =
                          upvoteNotifier.postUpvote(widget.item);
                      pageNotifier.updatePostUpvote(
                        widget.item.postId ?? "",
                        result,
                        context,
                      );
                    },
                    child: Row(
                      children: [
                        count != 0
                            ? Text(
                                "$count",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.item.upvote!
                                          .contains(UserInfoConfig.uniqueID)
                                      ? Colors.red
                                      : const Color(0xFF052D84)
                                          .withOpacity(0.2),
                                ),
                              )
                            : const SizedBox.shrink(),
                        Image.asset(
                          "assets/like_icon.png",
                          height: 28,
                          width: 28,
                          color: widget.item.upvote!
                                  .contains(UserInfoConfig.uniqueID)
                              ? Colors.red
                              : const Color(0xFF052D84).withOpacity(0.2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(65, 10, 20, 0),
          alignment: Alignment.centerLeft,
          child: Text(
            widget.item.postContent,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Color(0xFF052D84),
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(65, 10, 0, 0),
          child: Row(
            children: [
              widget.item.postImages.isNotEmpty
                  ? Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/galleryPhotoView",
                              arguments: GalleryPhotoViewArguments(
                                imageUrls: widget.item.postImages,
                                initialIndex: 0,
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              width: widget.screenWidth * (2 / 3),
                              imageUrl: widget.item.postImages[0],
                              maxWidthDiskCache: widget.screenWidth.toInt(),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/image_more_icon.png",
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "X${widget.item.postImages.length}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _buildPlaceholder(widget.screenWidth),
            ],
          ),
        ),
        widget.item.userID != UserInfoConfig.uniqueID
            ? Padding(
                padding: const EdgeInsets.fromLTRB(65, 10, 10, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/chatDetailPage",
                          arguments: ChatDetailPageArguments(
                            taUserName: widget.item.userName,
                            taUserAvatar: widget.item.userAvatar,
                            taUserID: widget.item.userID ?? "",
                          ),
                        );
                      },
                      child: Container(
                        width: widget.screenWidth * (2 / 3),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '点击可直接和TA取得联系~',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.7,
                            color: const Color(0xFF052D84).withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(height: 35),
      ],
    );
  }

  Widget _buildPlaceholder(double screenWidth) {
    return Container(
      height: 380,
      width: screenWidth * (2 / 3),
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
  }
}
