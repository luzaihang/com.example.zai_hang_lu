import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:zai_hang_lu/app_data/user_info_config.dart';
import 'package:zai_hang_lu/route_generator.dart';

class PostWidget extends StatelessWidget {
  final String username;
  final String userID;
  final String userAvatar;
  final String postTime;
  final String location;
  final String message;
  final List<String> images;

  const PostWidget({
    super.key,
    required this.username,
    required this.userID,
    required this.postTime,
    required this.location,
    required this.message,
    required this.images,
    required this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    double bottom = 20.0;
    List<String> displayImages =
        images.length > 2 ? images.sublist(0, 2) : images;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
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
      ))),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              userAvatar.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(userAvatar),
                      radius: 24.0,
                    )
                  : const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      radius: 24.0,
                      child: Icon(Icons.person),
                    ),
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
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          postTime,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12.0),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          location,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        userID != UserInfoConfig.userID
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 0.7),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Text(
                  '联系TA',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildMessage() {
    return Text(
      message,
      style: const TextStyle(fontSize: 16.0, color: Colors.blueGrey),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildImages(BuildContext context, List<String> displayImages,
      double bottom, List<String> allImages) {
    return Row(
      children: List.generate(2, (index) {
        if (displayImages.length <= index || displayImages[index].isEmpty) {
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
              margin: EdgeInsets.only(
                  right: index == 0 ? 8.0 : 0.0, bottom: bottom),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: userAvatar.isNotEmpty
                    ? CachedNetworkImage(
                        height: 220,
                        imageUrl: displayImages[index],
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[300]),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                      )
                    : Container(),
              ),
            ),
          ),
        );
      }),
    );
  }
}
