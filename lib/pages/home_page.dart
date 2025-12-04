// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xnetwork/xnetwork.dart';
import '../models/server_model.dart';
import '../services/server_storage.dart';
import '../widgets/connection_card.dart';
import '../widgets/server_item.dart';
import '../widgets/connect_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';
  late TextEditingController _configController;
  final ServerStorage _serverStorage = ServerStorage();

  // Mock data
  final List<ServerModel> _servers = [
    ServerModel(
      id: '1',
      name: 'VIP-v2ray-Singapore 01',
      address: 'apollo.apollogc.cloud',
      port: 30007,
      type: 'vmess',
      flag: '🇸🇬',
      isSelected: true,
      url:
          "vless://1d91601f-a63e-4500-9655-c4189d197816@206.82.4.34:443?encryption=none&security=reality&sni=www.cloudflare.com&fp=chrome&pbk=rEMZy3ADfCXxsyBbgDYNwIZ7Ai4IeSeRaiqU5gvWxgI&sid=12345678&type=tcp&headerType=none&host=www.cloudflare.com#%F0%9F%87%BA%F0%9F%87%B8%E7%BE%8E%E5%9B%BD",
    ),
  ];

  ServerModel selectedServer = ServerModel(
    id: '1',
    name: 'VIP-v2ray-Singapore 01',
    address: 'apollo.apollogc.cloud',
    port: 30007,
    type: 'vmess',
    flag: '🇸🇬',
    isSelected: true,
    url:
        "vless://1d91601f-a63e-4500-9655-c4189d197816@206.82.4.34:443?encryption=none&security=reality&sni=www.cloudflare.com&fp=chrome&pbk=rEMZy3ADfCXxsyBbgDYNwIZ7Ai4IeSeRaiqU5gvWxgI&sid=12345678&type=tcp&headerType=none&host=www.cloudflare.com#%F0%9F%87%BA%F0%9F%87%B8%E7%BE%8E%E5%9B%BD",
  );

  @override
  void initState() {
    super.initState();
    _configController = TextEditingController(text: selectedServer.url);
    _loadServers();
  }

  Future<void> _loadServers() async {
    final storedServers = await _serverStorage.loadServers();
    if (storedServers.isNotEmpty) {
      setState(() {
        _servers.clear();
        _servers.addAll(storedServers);
      });
    }
  }

  @override
  void dispose() {
    _configController.dispose();
    super.dispose();
  }

  Future<void> _toggleConnection() async {
    if (_isConnected) {
      await Xnetwork.stop();
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Disconnected';
      });
    } else {
      // Use the selected server's URL if available, otherwise fallback to the input text (though input text is usually for adding new ones)
      // If the selected server has a URL, use it.
      String configUrl = selectedServer.url!;
      var ok = await Xnetwork.start(configUrl, true);
      debugPrint("start $ok");
      setState(() {
        _isConnected = true;
        _connectionStatus = 'Connected';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedServer = _servers.firstWhere(
      (s) => s.isSelected,
      orElse: () => _servers.first,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8EAF6),
              const Color(0xFFF5F6F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48), // Balance the layout
          const Text(
            'sing-box',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: Image.asset(
              "assets/images/lock.heart.fill.png",
              width: 25,
              height: 25,
            ),
            onPressed: () async {
              Xnetwork.getVPNPermission();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final selectedServer = _servers.firstWhere(
      (s) => s.isSelected,
      orElse: () => _servers.first,
    );

    return Column(
      children: [
        // Top Config Area (Input)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, 4),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Stack(
            alignment: AlignmentGeometry.bottomRight,
            children: [
              SizedBox(
                height: 88,
                child: TextField(
                  controller: _configController,
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter url here...',
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.save, color: Colors.blue, size: 22),
                      onPressed: () async {
                        final url = _configController.text;
                        if (url.isEmpty) return;

                        var node = await Xnetwork.parse(url);
                        if (node != null) {
                          // Check for duplicates
                          final isDuplicate = _servers.any(
                            (s) => s.url == node.url,
                          );
                          if (isDuplicate) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Server already exists'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                            return;
                          }

                          final newServer = ServerModel(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: node.remark.isNotEmpty
                                ? node.remark
                                : 'New Server',
                            address: node.address,
                            port: node.port,
                            type: node.scheme,
                            flag: '🌐', // Default flag
                            url: node.url,
                          );

                          setState(() {
                            _servers.add(newServer);
                          });
                          _serverStorage.saveServers(_servers);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Server added successfully'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to parse URL'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Connection Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConnectionCard(
            remark: selectedServer.name,
            address: selectedServer.address,
            port: selectedServer.port.toString(),
            status: _connectionStatus,
            protocol: selectedServer.type,
          ),
        ),

        const SizedBox(height: 16),

        // Connect Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConnectButton(
            isConnected: _isConnected,
            onPressed: _toggleConnection,
          ),
        ),

        const SizedBox(height: 20),

        // Server List
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, -5),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _servers.length,
                    itemBuilder: (context, index) {
                      final server = _servers[index];
                      return ServerItem(
                        server: server,
                        onTap: () {
                          setState(() {
                            // Simple toggle for demo
                            final newServers = _servers
                                .map(
                                  (s) => s.copyWith(isSelected: s.id == server.id),
                                )
                                .toList();
                            _servers.clear();
                            _servers.addAll(newServers);
                          });
                        },
                        onDelete: () {
                          setState(() {
                            _servers.removeWhere((s) => s.id == server.id);
                          });
                          _serverStorage.saveServers(_servers);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _oldBuild(BuildContext context) {
    final selectedServer = _servers.firstWhere(
      (s) => s.isSelected,
      orElse: () => _servers.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
        //   onPressed: () {},
        // ),
        title: const Text(
          'sing-box',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset(
              "assets/images/lock.heart.fill.png",
              width: 25,
              height: 25,
            ),
            onPressed: () async {
              Xnetwork.getVPNPermission();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Config Area (Input)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Stack(
              alignment: AlignmentGeometry.bottomRight,
              children: [
                SizedBox(
                  height: 88,
                  child: TextField(
                    controller: _configController,
                    maxLines: 3,
                    minLines: 1,
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter url here...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.blue),
                      onPressed: () async {
                        final url = _configController.text;
                        if (url.isEmpty) return;

                        var node = await Xnetwork.parse(url);
                        if (node != null) {
                          // Check for duplicates
                          final isDuplicate = _servers.any(
                            (s) => s.url == node.url,
                          );
                          if (isDuplicate) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Server already exists'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                            return;
                          }

                          final newServer = ServerModel(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: node.remark.isNotEmpty
                                ? node.remark
                                : 'New Server',
                            address: node.address,
                            port: node.port,
                            type: node.scheme,
                            flag: '🌐', // Default flag
                            url: node.url,
                          );

                          setState(() {
                            _servers.add(newServer);
                          });
                          _serverStorage.saveServers(_servers);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Server added successfully'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to parse URL'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Connection Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConnectionCard(
              remark: selectedServer.name,
              address: selectedServer.address,
              port: selectedServer.port.toString(),
              status: _connectionStatus,
              protocol: selectedServer.type,
            ),
          ),

          const SizedBox(height: 14),

          // Connect Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConnectButton(
              isConnected: _isConnected,
              onPressed: _toggleConnection,
            ),
          ),

          const SizedBox(height: 14),

          // Server List
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _servers.length,
                itemBuilder: (context, index) {
                  final server = _servers[index];
                  return ServerItem(
                    server: server,
                    onTap: () {
                      setState(() {
                        // Simple toggle for demo
                        final newServers = _servers
                            .map(
                              (s) => s.copyWith(isSelected: s.id == server.id),
                            )
                            .toList();
                        _servers.clear();
                        _servers.addAll(newServers);
                      });
                    },
                    onDelete: () {
                      setState(() {
                        _servers.removeWhere((s) => s.id == server.id);
                      });
                      _serverStorage.saveServers(_servers);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
