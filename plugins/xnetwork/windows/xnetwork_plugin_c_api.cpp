#include "include/xnetwork/xnetwork_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "xnetwork_plugin.h"

void XnetworkPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  xnetwork::XnetworkPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
