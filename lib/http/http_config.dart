import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpConfig {
  /// get请求
  Future<void> fetchGetData(String url) async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));

    if (response.statusCode == 200) {
      // 如果服务器返回 200 OK 的响应, 使用 utf8.decode() 函数转码, 防止中文乱码
      var responseData = json.decode(utf8.decode(response.bodyBytes));
      return responseData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  /// post请求
  Future<void> sendPostData(String url) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': 'foo',
        'body': 'bar',
        'userId': '1',
      }),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(utf8.decode(response.bodyBytes));
      return responseData;
    } else {
      throw Exception('Failed to send data');
    }
  }
}