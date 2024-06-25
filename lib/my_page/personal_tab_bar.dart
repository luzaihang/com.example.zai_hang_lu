import 'package:ci_dong/provider/personal_page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalTabBar extends StatelessWidget {
  final TabController tabController;

  const PersonalTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 150,
          height: 40,
          child: TabBar(
            controller: tabController,
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

  TextStyle _getTabTextStyle(BuildContext context, int index) {
    final selectedIndex = context.watch<PersonalPageNotifier>().selectedIndex;
    return TextStyle(
      fontSize: selectedIndex == index ? 18 : 16,
      fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
      color: const Color(0xFF052D84),
    );
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