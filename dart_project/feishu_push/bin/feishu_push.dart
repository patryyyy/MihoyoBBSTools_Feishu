import 'package:args/args.dart';

import 'package:feishu_push/feishu_push.dart';

void main(List<String> args) async {
  // 解析命令行参数
  ArgParser argParser = ArgParser();

  argParser.addOption('webhook', abbr: 'w', mandatory: true);
  argParser.addOption('sign', abbr: 's');

  final result = argParser.parse(args);
  final rest = result.rest;

  if (rest.isEmpty) {
    Pipe.err('feishu_push: 没有传入消息卡片参数');
  }

  // 解析消息卡片参数
  String cardName = '';
  List<String> values = [];

  if (rest.length > 1) {
    Pipe.err('feishu_push: 参数格式错误');
  } else {
    // card_name:value1,value2,value3...
    RegExp reg = RegExp(r'([^:]+):\s*([^,]+(?:,\s*[^,]+)*)');
    final matchs = reg.allMatches(rest.first);

    // 分离消息卡片的名称和参数
    for (var value in matchs) {
      try {
        cardName = value.group(1)!.trim();
        values = value.group(2)!.split(',').map((element) {
          return element.trim();
        }).toList();
      } catch (e) {
        Pipe.err('feishu_push: 参数解析错误');
      }
    }
  }

  String webhook = result['webhook'] ?? '';
  String sign = result['sign'] ?? '';

  if (webhook.isEmpty) {
    Pipe.err('feishu_push: webhook地址为空\n');
  }

  sendMessage(cardName: cardName, values: values, webhook: webhook, sign: sign);
  Pipe.ok('feishu_push: 推送成功');
}

void sendMessage(
    {required String cardName,
    required List<String> values,
    required String webhook,
    required String sign}) {
  if (cardName.isEmpty || values.isEmpty) {
    Pipe.err('feishu_push: 没有指定消息卡片和消息内容\n');
  }

  FeishuPush feishuPush = FeishuPush(webhook, sign);

  // 根据消息卡片名称发送消息
  switch (cardName) {
    case 'message':
      if (values.length != 1) {
        Pipe.err('feishu_push: 需要1个参数, 但是传入了${values.length}个参数\n');
      } else {
        feishuPush.sendMessage(Message(values.first));
      }
      break;
    case 'message_card':
      if (values.length != 2) {
        Pipe.err('feishu_push: 需要2个参数, 但是传入了${values.length}个参数\n');
      } else {
        feishuPush.sendMessage(MessageCard(values[0], values[1]));
      }
      break;
    case 'message_card_with_url':
      if (values.length != 3) {
        Pipe.err('feishu_push: 需要3个参数, 但是传入了${values.length}个参数\n');
      } else {
        feishuPush
            .sendMessage(MessageCardWithUrl(values[0], values[1], values[2]));
      }
      break;
    default:
      Pipe.err('feishu_push: 不支持的消息卡片\n');
  }
}
