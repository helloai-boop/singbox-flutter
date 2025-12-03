#ifndef FLUTTER_PLUGIN_XNETWORK_PLUGIN_H_
#define FLUTTER_PLUGIN_XNETWORK_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace xnetwork {

class XnetworkPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  XnetworkPlugin();

  virtual ~XnetworkPlugin();

  // Disallow copy and assign.
  XnetworkPlugin(const XnetworkPlugin&) = delete;
  XnetworkPlugin& operator=(const XnetworkPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace xnetwork

#endif  // FLUTTER_PLUGIN_XNETWORK_PLUGIN_H_
