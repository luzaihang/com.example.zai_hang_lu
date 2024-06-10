import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';
import 'package:zai_hang_lu/global_component/route_generator.dart';

class HomePostItem extends StatelessWidget {
  final String username;
  final String userID;
  final String userAvatar;
  final String postTime;
  final String location;
  final String message;
  final List<String> images;

  const HomePostItem({
    Key? key,
    required this.username,
    required this.userID,
    required this.postTime,
    required this.location,
    required this.message,
    required this.images,
    required this.userAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double bottom = 20.0;
    List<String> displayImages = images.take(2).toList(); // 简化处理子列表

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildMessage(),
          SizedBox(height: displayImages.isEmpty ? bottom : 12.0),
          _buildImages(context, displayImages, bottom, images),
          _cutLine(),
        ],
      ),
    );
  }

  Widget _cutLine() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.3,
            color: Colors.blueGrey.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      children: [
                        _buildInfoText(postTime),
                        const SizedBox(width: 6.0),
                        _buildInfoText(location),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (userID != UserInfoConfig.userID)
          _buildContactButton(context),
      ],
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundImage: userAvatar.isNotEmpty
          ? CachedNetworkImageProvider(userAvatar)
          : null,
      backgroundColor: userAvatar.isEmpty ? Colors.blueGrey : null,
      radius: 20.0,
      child: userAvatar.isEmpty ? const Icon(Icons.person) : null,
    );
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey, fontSize: 11.0),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/chatDetailPage',
          arguments: ChatDetailPageArguments(
            taUserName: username,
            taUserID: userID,
            taUserAvatar: userAvatar,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withOpacity(0.5), width: 0.5),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child:  Text(
          '联系TA',
          style: TextStyle(
            color: Colors.blue.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      message,
      style: const TextStyle(fontSize: 14.0, color: Colors.blueGrey),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildImages(
      BuildContext context, List<String> displayImages, double bottom, List<String> allImages) {
    return Row(
      children: List.generate(2, (index) {
        if (index >= displayImages.length) {
          return const Expanded(child: SizedBox.shrink());
        }
        return Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                "/galleryPhotoView",
                arguments: GalleryPhotoViewArguments(
                  imageUrls: allImages,
                  initialIndex: index,
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: index == 0 ? 8.0 : 0.0, bottom: bottom),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  height: 220,
                  imageUrl: displayImages[index],
                  placeholder: (context, url) => Container(color: Colors.grey[300]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}