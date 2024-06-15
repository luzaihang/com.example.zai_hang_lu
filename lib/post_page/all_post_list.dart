import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AllPostListWidget extends StatefulWidget {
  const AllPostListWidget({super.key});

  @override
  State<AllPostListWidget> createState() => _AllPostListWidgetState();
}

class _AllPostListWidgetState extends State<AllPostListWidget> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, index == 0 ? 20 : 0, 20, 0),
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
                          const Text(
                            '缘聚缘散缘如水',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF052D84),
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
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
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        "assets/like_icon.png",
                        height: 28,
                        width: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(65, 10, 20, 0),
                child: Text(
                  '刚发现我车上被贴了这种东西贴在不显眼的位置好像是某种符有人知道这是啥吗?',
                  style: TextStyle(
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
                    Stack(
                      // alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            width: screenWidth * (2 / 3),
                            imageUrl:
                                'https://user-info-1322814250.cos.ap-shanghai.myqcloud.com/241718341476_.pic.jpg',
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
                              const Text(
                                "X6",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(65, 10, 10, 20),
                child: Row(
                  children: [
                    Container(
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
                  ],
                ),
              ),
            ],
          );
        },
        childCount: 5,
      ),
    );
  }
}
