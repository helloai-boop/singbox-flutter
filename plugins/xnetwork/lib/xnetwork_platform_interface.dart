import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'xnetwork_method_channel.dart';

abstract class XnetworkPlatform extends PlatformInterface {
  /// Constructs a XnetworkPlatform.
  XnetworkPlatform() : super(token: _token);

  static final Object _token = Object();

  static XnetworkPlatform _instance = MethodChannelXnetwork();

  /// The default instance of [XnetworkPlatform] to use.
  ///
  /// Defaults to [MethodChannelXnetwork].
  static XnetworkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XnetworkPlatform] when
  /// they register themselves.
  static set instance(XnetworkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> getVPNPermission() async {
    throw UnimplementedError('getVPNPermission() has not been implemented.');
  }

  Future<bool> start(
    String url,
    bool isGlobalMode, {
    Map<String, dynamic> parameters = const {},
  }) async {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<bool> stop() async {
    throw UnimplementedError('stop() has not been implemented.');
  }
}
