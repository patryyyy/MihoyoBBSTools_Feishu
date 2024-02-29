import 'dart:io';

class Pipe {
  static final File _pipe = File('/tmp/communicate_with_feishu_push');

  static void ok(String message) {
    _pipe.writeAsStringSync(message);
  }

  static void err(String message) {
    _pipe.writeAsStringSync(message);
    exit(1);
  }
}
