import 'package:flutter/material.dart';

class VipPage extends StatelessWidget {
  const VipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF2F3F5),
      body: Center(),
    );
  }
}

void showVipModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.7, // 底部弹窗占屏幕高度的 70%
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'VIP简介',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF052D84),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.message,
                                  color: Color(0xFF052D84), size: 40),
                              Text(
                                '消息气泡',
                                style: TextStyle(color: Color(0xFF052D84)),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.card_giftcard,
                                  color: Color(0xFF052D84), size: 40),
                              Text(
                                '专属守护/礼物',
                                style: TextStyle(color: Color(0xFF052D84)),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.visibility,
                                  color: Color(0xFF052D84), size: 40),
                              Text(
                                '谁看过我',
                                style: TextStyle(color: Color(0xFF052D84)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SubscriptionOption(
                            price: '¥298',
                            originalPrice: '¥360',
                            duration: '一年',
                          ),
                          SubscriptionOption(
                            price: '¥138',
                            originalPrice: '¥180',
                            duration: '半年',
                          ),
                          SubscriptionOption(
                            price: '¥78',
                            originalPrice: '¥90',
                            duration: '三个月',
                          ),
                          SubscriptionOption(
                            price: '¥30',
                            originalPrice: '¥30',
                            duration: '一个月',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(),
                      SizedBox(height: 20),
                      ListTile(
                        leading: Icon(Icons.payment, color: Colors.green),
                        title: Text(
                          '支付宝支付',
                          style: TextStyle(color: Color(0xFF052D84)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // 在这里处理开通VIP的逻辑
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF052D84),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // 圆角半径为10
                      ),
                    ),
                    child: const Text(
                      '同意协议并开通VIP ¥298',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (bool? value) {}),
                      const Expanded(
                        child: Text(
                          '开通前确认《VIP服务协议、VIP订阅服务协议》',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF052D84)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}

class SubscriptionOption extends StatelessWidget {
  final String price;
  final String originalPrice;
  final String duration;

  const SubscriptionOption({
    super.key,
    required this.price,
    required this.originalPrice,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          price,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF052D84),
          ),
        ),
        Text(
          originalPrice,
          style: const TextStyle(
            fontSize: 12,
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        Text(
          duration,
          style: const TextStyle(color: Color(0xFF052D84)),
        ),
      ],
    );
  }
}
