import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class FeishuPush {
  final String _webhookUrl;
  final String? _signature;

  FeishuPush(this._webhookUrl, [this._signature]);

  Future<void> sendMessage(Message message) async {
    Map<String, dynamic> msg = message.msg;

    if (_signature != '' || _signature != null) {
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String sign = _generateSecret(_signature!, timestamp);

      msg["timestamp"] = timestamp.toString();
      msg["sign"] = sign;
    }

    await Dio().post(_webhookUrl, data: jsonEncode(msg));
  }

  String _generateSecret(String secret, int timestamp) {
    // 把timestamp+"\n"+密钥当做签名字符串
    String stringToSign = '$timestamp\n$secret';

    // 使用HmacSHA256算法计算签名
    var hmac = Hmac(sha256, utf8.encode(stringToSign));
    var signData = hmac.convert(utf8.encode(''));

    return base64.encode(signData.bytes);
  }
}

class Message {
  Map<String, dynamic>? _msg;

  Message(String msg) {
    Map<String, dynamic> str = {
      "msg_type": "text",
      "content": {"text": msg}
    };

    _msg = str;
  }

  Map<String, dynamic> get msg {
    return _msg!;
  }
}

class MessageCard implements Message {
  @override
  Map<String, dynamic>? _msg;

  MessageCard(String title, String content) {
    Map<String, dynamic> str = {
      "msg_type": "interactive",
      "card": {
        "elements": [
          {
            "tag": "div",
            "text": {"content": content, "tag": "plain_text"}
          },
        ],
        "header": {
          "template": "blue",
          "title": {"content": title, "tag": "plain_text"}
        }
      },
      "mock_data": "{}",
      "variables": []
    };

    _msg = str;
  }

  @override
  Map<String, dynamic> get msg {
    return _msg!;
  }
}

class MessageCardWithUrl implements Message {
  @override
  Map<String, dynamic>? _msg;

  MessageCardWithUrl(String title, String content, String url) {
    Map<String, dynamic> str = {
      "msg_type": "interactive",
      "card": {
        "elements": [
          {
            "tag": "div",
            "text": {"content": content, "tag": "plain_text"}
          },
          {"tag": "hr"},
          {
            "tag": "action",
            "actions": [
              {
                "tag": "button",
                "text": {"tag": "plain_text", "content": "更多信息"},
                "type": "primary",
                "url": url
              }
            ]
          }
        ],
        "header": {
          "template": "blue",
          "title": {"content": title, "tag": "plain_text"}
        }
      },
      "mock_data": "{}",
      "variables": []
    };

    _msg = str;
  }

  @override
  Map<String, dynamic> get msg {
    return _msg!;
  }
}
