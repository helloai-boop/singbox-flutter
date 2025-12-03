import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'xnetwork_platform_interface.dart';

/// An implementation of [XnetworkPlatform] that uses method channels.
class MethodChannelXnetwork extends XnetworkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xnetwork');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> getVPNPermission() async {
    final version = await methodChannel.invokeMethod<bool>('getVPNPermission');
    return version ?? false;
  }

  @override
  Future<bool> start(
    String url,
    bool isGlobalMode, {
    Map<String, dynamic> parameters = const {},
  }) async {
    final ok = await methodChannel.invokeMethod<bool>('start', {
      "url": url,
      "global": isGlobalMode,
      "parameters": parameters,
    });
    return ok ?? false;
  }

  @override
  Future<bool> stop() async {
    final ok = await methodChannel.invokeMethod<bool>('stop');
    return ok ?? false;
  }
}
