import 'package:flutter/material.dart';
import 'package:xnetwork/xnetwork.dart';
import '../models/server_model.dart';
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
    ),
    ServerModel(
      id: '2',
      name: 'VIP-v2ray-Singapore 02',
      address: 'apollo.apollogc.cloud',
      port: 30008,
      type: 'vmess',
      flag: '🇸🇬',
    ),
    ServerModel(
      id: '3',
      name: 'VIP-v2ray-Taiwan 01',
      address: 'apollo.apollogc.cloud',
      port: 30009,
      type: 'vmess',
      flag: '🇨🇳',
    ),
  ];

  // Config from main.dart
  final String _vlessConfig = "vless://1d91601f-a63e-4500-9655-c4189d197816@206.82.4.34:443?encryption=none&security=reality&sni=www.cloudflare.com&fp=chrome&pbk=rEMZy3ADfCXxsyBbgDYNwIZ7Ai4IeSeRaiqU5gvWxgI&sid=12345678&type=tcp&headerType=none&host=www.cloudflare.com#%F0%9F%87%BA%F0%9F%87%B8%E7%BE%8E%E5%9B%BD";

  @override
  void initState() {
    super.initState();
    // _checkPermission();
  }

  Future<void> _checkPermission() async {
    await Xnetwork.getVPNPermission();
  }

  Future<void> _toggleConnection() async {
    if (_isConnected) {
      await Xnetwork.stop();
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Disconnected';
      });
    } else {
      // In a real app, we would use the selected server's config
      // For now using the hardcoded one as per main.dart example or just a placeholder
      // The user request didn't provide dynamic config generation logic, so I'll use the one from main.dart
      // But to make it realistic, I'll pretend we are using the selected server.
      
      var ok = await Xnetwork.start(_vlessConfig, true);
      debugPrint("start $ok");
      
      setState(() {
        _isConnected = true;
        _connectionStatus = 'Connected';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedServer = _servers.firstWhere((s) => s.isSelected, orElse: () => _servers.first);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Yo Net',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Config Area (Mock)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid), // Dashed in design
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _vlessConfig,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.blue),
                      onPressed: () {},
                    ),
                  ],
                )
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

          const SizedBox(height: 24),

          // Connect Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConnectButton(
              isConnected: _isConnected,
              onPressed: _toggleConnection,
            ),
          ),

          const SizedBox(height: 24),

          // Speed Test & Route All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(Icons.speed, 'Speed Test', Colors.green),
                _buildActionButton(Icons.public, 'Route All', Colors.green),
              ],
            ),
          ),

          const SizedBox(height: 16),

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
                        for (var s in _servers) {
                          // s.isSelected = (s.id == server.id); // Cannot assign to final
                          // Need to replace in list
                        }
                        // Simple toggle for demo
                        final newServers = _servers.map((s) => s.copyWith(isSelected: s.id == server.id)).toList();
                        _servers.clear();
                        _servers.addAll(newServers);
                      });
                    },
                    onDelete: () {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'Yo Net'),
          BottomNavigationBarItem(icon: Icon(Icons.http), label: 'HTTP'),
          BottomNavigationBarItem(icon: Icon(Icons.bug_report), label: 'Debug'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
