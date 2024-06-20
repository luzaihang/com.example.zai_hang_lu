import 'package:cached_network_image/cached_network_image.dart';
import 'package:ci_dong/app_data/user_info_config.dart';
import 'package:ci_dong/default_config/default_config.dart';
import 'package:ci_dong/factory_list/home_list_data.dart';
import 'package:ci_dong/global_component/route_generator.dart';
import 'package:ci_dong/routes_widgets/chat_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostListItem extends StatelessWidget {
  final UserPost item;
  final double screenWidth;
  final int index;

  const PostListItem(
      {required this.item,
      required this.screenWidth,
      required this.index,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, index == 0 ? 15 : 0, 20, 0),
          child: Row(
            children: [
              Image.asset(
                "assets/chat_icon.png",
                height: 36,
                width: 36,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF052D84),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '累计获赞: 10000次',
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF052D84).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              item.userID != UserInfoConfig.uniqueID
                  ? GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        "assets/like_icon.png",
                        height: 28,
                        width: 28,
                      ),
                    )
                  : const SizedBox(width: 28),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(65, 10, 20, 0),
          alignment: Alignment.centerLeft,
          child: Text(
            item.postContent,
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
              item.postImages.isNotEmpty
                  ? Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/galleryPhotoView",
                              arguments: GalleryPhotoViewArguments(
                                imageUrls: item.postImages,
                                initialIndex: 0,
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              width: screenWidth * (2 / 3),
                              imageUrl: item.postImages.isNotEmpty
                                  ? item.postImages[0]
                                  : DefaultConfig.bannerImg,
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
                                "X${item.postImages.length}",
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
                  : _buildPlaceholder(screenWidth),
            ],
          ),
        ),
        item.userID != UserInfoConfig.uniqueID
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
                            taUserName: item.userName,
                            taUserAvatar: item.userAvatar,
                            taUserID: item.userID ?? "",
                          ),
                        );
                      },
                      child: Container(
                        width: screenWidth * (2 / 3),
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
