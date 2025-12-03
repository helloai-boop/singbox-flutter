// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'xnetwork_platform_interface.dart';
import 'dart:io';

class Xnetwork {
  static Future<String?> getPlatformVersion() {
    return XnetworkPlatform.instance.getPlatformVersion();
  }

  static Future<bool> getVPNPermission() async {
    if (Platform.isWindows) {
      return true;
    }
    return XnetworkPlatform.instance.getVPNPermission();
  }

  static Future<bool> start(
    String url,
    bool isGlobalMode, {
    Map<String, dynamic> parameters = const {},
  }) async {
    if (Platform.isWindows) {
      return await startWindows(url, isGlobalMode, parameters: parameters);
    } else if (Platform.isMacOS) {
      return await startMac(url, isGlobalMode, parameters: parameters);
    }
    return await XnetworkPlatform.instance.start(
      url,
      isGlobalMode,
      parameters: parameters,
    );
  }

  static debug(Object? object) {
    debugPrint("$object");
  }

  static Future<bool> stop() async {
    if (Platform.isWindows) {
      return await stopWindows();
    } else if (Platform.isMacOS) {
      return await stopMac();
    }
    return await XnetworkPlatform.instance.stop();
  }

  static Future<bool> stopWindows() async {
    try {
      final process = await Process.start(
        "taskkill",
        ["/IM", "singbox.exe", "/F"], // 示例参数
        runInShell: true,
      );

      process.stdout.transform(const Utf8Decoder()).listen(debug);
      process.stderr.transform(const Utf8Decoder()).listen(debug);
      return true;
    } catch (e) {
      debugPrint("stop exception:$e");
    }

    return false;
  }

  static Future<bool> startWindows(
    String url,
    bool isGlobalMode, {
    Map<String, dynamic> parameters = const {},
  }) async {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final singBoxPath = '$exeDir/singbox.exe';

    //  .\singbox.exe run -D . -u "vless://1d91601f-a63e-4500-9655-c4189d197816@206.82.4.34:443?encryption=none&security=reality&sni=www.cloudflare.com&fp=chrome&pbk=rEMZy3ADfCXxsyBbgDYNwIZ7Ai4IeSeRaiqU5gvWxgI&sid=12345678&type=tcp&headerType=none&host=www.cloudflare.com#%F0%9F%87%BA%F0%9F%87%B8%E7%BE%8E%E5%9B%BD" -g true
    debugPrint(exeDir);

    // final process = await Process.start(
    //   singBoxPath,
    //   ['run', '-D', exeDir, "-u", url, "-g", "$isGlobalMode"], // 示例参数
    //   workingDirectory: exeDir,
    //   runInShell: true,
    //   includeParentEnvironment: true
    // );

      // 使用 shell 执行
    final arguments = ['run', '-D', exeDir, "-u", url, "-g", "$isGlobalMode"];
    await Process.run(
      'powershell',
      [ '-NoProfile',
        '-NonInteractive',
        '-WindowStyle', 'Hidden',  '-Command', 'Start-Process', '-FilePath', '\'$singBoxPath\'', 
      '-ArgumentList', '\'${arguments.join(' ')}\'', '-WindowStyle', 'Hidden',
    '-PassThru', '|', 'Out-Null'], // 如果需要管理员权限
      runInShell: false,
    );

    // process.stdout.transform(const Utf8Decoder()).listen(debug);
    // process.stderr.transform(const Utf8Decoder()).listen(debug);

    return true;
  }

  static Future<bool> stopMac() async {
    final singBoxPath = '/Library/Application Support/xxnetwork/xxnetwork';
    final process = await Process.start(
      singBoxPath,
      ['stop'], // 示例参数
      runInShell: true,
    );
    await Process.run("networksetup", ["-setdnsservers", "wi-fi", "empty"]);
    process.stdout.transform(const Utf8Decoder()).listen(debug);
    process.stderr.transform(const Utf8Decoder()).listen(debug);
    return true;
  }

  static Future<bool> startMac(
    String url,
    bool isGlobalMode, {
    Map<String, dynamic> parameters = const {},
  }) async {
    //  .\singbox.exe run -D . -u "vless://1d91601f-a63e-4500-9655-c4189d197816@206.82.4.34:443?encryption=none&security=reality&sni=www.cloudflare.com&fp=chrome&pbk=rEMZy3ADfCXxsyBbgDYNwIZ7Ai4IeSeRaiqU5gvWxgI&sid=12345678&type=tcp&headerType=none&host=www.cloudflare.com#%F0%9F%87%BA%F0%9F%87%B8%E7%BE%8E%E5%9B%BD" -g true

    final executablePath = Platform.resolvedExecutable;
    final appBundlePath = Directory(executablePath).parent.parent.parent;
    final resourcesPath = Directory('${appBundlePath.path}/Contents/Resources');
    if (!(await resourcesPath.exists())) {
      return false;
    }
    await Process.run("networksetup", ["-setdnsservers", "wi-fi", "8.8.8.8"]);
    final singBoxPath = '/Library/Application Support/xxnetwork/xxnetwork';
    final process = await Process.start(
      singBoxPath,
      [
        'run',
        '-D',
        resourcesPath.path,
        "-u",
        url,
        "-g",
        "$isGlobalMode",
      ], // 示例参数
      runInShell: true,
    );
    process.stdout.transform(const Utf8Decoder()).listen(debug);
    process.stderr.transform(const Utf8Decoder()).listen(debug);
    return true;
  }
}
