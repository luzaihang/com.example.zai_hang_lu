import 'package:ci_dong/factory_list/chat_detail_from_map.dart';
import 'package:ci_dong/lean_cloud/client_manager.dart';
import 'package:ci_dong/tencent/tencent_cloud_download.dart';
import 'package:ci_dong/tencent/tencent_cloud_upload.dart';
import 'package:flutter/material.dart';
import 'package:leancloud_official_plugin/leancloud_plugin.dart';

class ChatNotifier with ChangeNotifier {
  Client client = ClientManager().client;

  String messageText = "";

  ///监听消息，bool是否是后台监听，后台监听则走这个方法内的上传,针对上传聊天记录到云端
  bool isDetail = false;

  void setupClientMessageListener() {
    List<ChatDetailFromMap> chatList = [];
    client.onMessage = ({
      required Client client,
      required Conversation conversation,
      required Message message,
    }) async {
      String? text = message is TextMessage ? message.text : '消息内容为空';
      messageText = text ?? "";
      if (text != null && text.isNotEmpty) notifyListeners();

      if (isDetail) return; //如果是聊天详情页面，则不走以下的逻辑。

      String senderUserid = message.fromClientID ?? ""; //发送人id
      chatList = await TencentCloudTxtDownload.chatTxt(senderUserid);

      String senderName = chatList.last.senderName;
      String senderAvatar = chatList.last.senderAvatar;

      ChatDetailFromMap detailSender = ChatDetailFromMap(
        senderName: senderName,
        senderID: senderUserid,
        senderAvatar: senderAvatar,
        message: messageText,
        time: DateTime.now().toString(),
      );

      chatList.add(detailSender);

      List<Map<String, dynamic>> listMap =
          chatList.map((detail) => detail.toMap()).toList();

      chatUpload(senderUserid, listMap);
    };
  }
}
