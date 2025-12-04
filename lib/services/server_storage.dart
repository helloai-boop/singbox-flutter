import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/server_model.dart';

class ServerStorage {
  static const String _keyServers = 'servers';

  Future<List<ServerModel>> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? serversJson = prefs.getString(_keyServers);
    if (serversJson == null) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(serversJson);
      return decoded.map((e) => ServerModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveServers(List<ServerModel> servers) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(servers.map((e) => e.toJson()).toList());
    await prefs.setString(_keyServers, encoded);
  }
}
