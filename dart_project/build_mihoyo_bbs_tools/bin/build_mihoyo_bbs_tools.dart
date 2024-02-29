import 'dart:io';

import 'package:build_mihoyo_bbs_tools/log.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:system/system.dart';

Log log = Log(
  filter: ProductionFilter(),
  printer: PrettyPrinter(methodCount: 0),
);

String path = current;

void main(List<String> args) {
  checkLinux();
  checkPython();
  checkPip();
  installPyDependencies();
  installDartDependencies();
  buildFeishuPush();
  buildStartMihoyoBBSTools();
  createServiceFile();
  reloadSystemdConfiguration();
  log.i('使用 `sudo systemctl start start_mihoyo_bbs_tools` 启动服务');
  // startMihoyoBBSTools();
}

void checkLinux() {
  log.i('正在检查当前环境是否为Linux');
  if (!Platform.isLinux) {
    log.e('不支持的操作系统, 仅支持Linux');
  }
}

void checkPython() {
  log.i('正在检查Python是否安装以及版本是否大于3.0');
  try {
    final pyVersion = runCommand(getPyexeName(), ['--version']).stdout.toString();
    if (!pyVersion.contains('Python 3')) {
      log.e('不支持的Python版本, 请使用Python 3.0及以上版本');
    }
  } catch (e) {
    log.e('未找到Python, 请确认是否安装以及环境变量是否配置');
  }
}

void checkPip() {
  log.i('正在检查pip是否安装');
  try {
    final pipVersion = runCommand(getPipexeName(), ['--version']).stdout.toString();
    if (!pipVersion.contains('python 3')) {
      log.e('不支持的pip版本, 请更新pip');
    }
  } catch (e) {
    log.e('未找到pip, 请确认是否安装以及环境变量是否配置');
  }
}

void installPyDependencies() {
  log.i('正在安装Python依赖');
  try {
    final install = runCommand(getPipexeName(), ['install', '-r', 'requirements.txt']);
    if (install.exitCode != 0) {
      log.e('pip 依赖下载失败');
    }
  } catch (e) {
    log.e('pip 依赖下载失败');
  }
}

void installDartDependencies() {
  log.i('正在安装Dart依赖');

  try {
    runCommand('dart', ['pub', 'get'], workingDirectory: '$path/dart_project/feishu_push');
  } catch (e) {
    log.e('Dart 依赖下载失败');
  }

  try {
    runCommand('dart', ['pub', 'get'], workingDirectory: '$path/dart_project/start_mihoyo_bbs_tools');
  } catch (e) {
    log.e('Dart 依赖下载失败');
  }
}

void buildFeishuPush() {
  log.i('正在编译feishu_push');
  try {
    final compile = runCommand('dart', ['compile', 'exe', 'dart_project/feishu_push/bin/feishu_push.dart', '-o', 'feishu_push']);
    if (compile.exitCode != 0) {
      log.e('feishu_push 编译失败');
    }
  } catch (e) {
    log.e('feishu_push 编译失败');
  }
}

void buildStartMihoyoBBSTools() {
  log.i('正在编译start_mihoyo_bbs_tools');
  try {
    final compile = runCommand('dart', ['compile', 'exe', 'dart_project/start_mihoyo_bbs_tools/bin/start_mihoyo_bbs_tools.dart', '-o', 'start_mihoyo_bbs_tools']);
    if (compile.exitCode != 0) {
      log.e('start_mihoyo_bbs_tools 编译失败, 请检查路径是否正确及start_mihoyo_bbs_tools服务是否已经关闭');
    }
  } catch (e) {
    log.e('start_mihoyo_bbs_tools 编译失败, 请检查路径是否正确及start_mihoyo_bbs_tools服务是否已经关闭');
  }
}

void createServiceFile() {
  log.i('正在创建服务文件');
  String serviceFile = '/etc/systemd/system/start_mihoyo_bbs_tools.service';
  String content =
'''[Unit]
Description=start_mihoyo_bbs_tools
After=network.service

[Service]
RestartSec=2s
Type=simple
ExecStart=$path/start_mihoyo_bbs_tools
Restart=always

[Install]
WantedBy=multi-user.target
''';
  String command = 
'''sudo bash -c "cat > $serviceFile <<EOF
${content}EOF"''';

  if (!System.invoke(command)) {
    log.e('服务文件创建失败');
  }

}

void reloadSystemdConfiguration() {
  log.i('正在重新加载systemd配置');

  if (!System.invoke('sudo systemctl daemon-reload')) {
    log.e('重新加载systemd配置失败');
  }
}

// void startMihoyoBBSTools() {
//   log.i('正在启动start_mihoyo_bbs_tools');

//   if (!System.invoke('sudo systemctl start start_mihoyo_bbs_tools')) {
//     log.e('`start_mihoyo_bbs_tools` 启动失败');
//   } else {
//     log.i('使用 `sudo systemctl status start_mihoyo_bbs_tools` 查看服务运行情况');
//   }
// }

String getPyexeName() {
  try {
    if (runCommand('python3', ['--version']).exitCode == 0) {
      return 'python3';
    }
    else if (runCommand('python', ['--version']).exitCode == 0) {
      return 'python';
    } else {
      log.e('未找到Python, 请确认是否安装以及环境变量是否配置');
    }
  } catch (e) {
    log.e('未找到Python, 请确认是否安装以及环境变量是否配置');
  }

  return '';
}

String getPipexeName() {
  try {
    if (runCommand('pip3', ['--version']).exitCode == 0) {
      return 'pip3';
    }
    else if (runCommand('pip', ['--version']).exitCode == 0) {
      return 'pip';
    } else {
      log.e('未找到pip, 请确认是否安装以及环境变量是否配置');
    }

  } catch (e) {
    log.e('未找到pip, 请确认是否安装以及环境变量是否配置');
  }

  return '';
}

void setPath(String value) {
  bool isDebug = false;
  assert(isDebug = true);

  if (isDebug) {
    path = '$current/../..';
  } else {
    path = value;
  }
}

ProcessResult runCommand(String exe, List<String> args, {String? workingDirectory}) {
  return Process.runSync(exe, args, runInShell: true, workingDirectory: workingDirectory ?? path);
}
