import 'package:flutter/material.dart';

class ConnectionCard extends StatelessWidget {
  final String remark;
  final String address;
  final String port;
  final String status;
  final String protocol; // e.g., vmess

  const ConnectionCard({
    super.key,
    required this.remark,
    required this.address,
    required this.port,
    required this.status,
    required this.protocol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow('Remark:', remark, isBold: true, trailing: const Icon(Icons.bar_chart, color: Colors.blue)),
          const SizedBox(height: 8),
          _buildRow('Address:', address),
          const SizedBox(height: 8),
          _buildRow('Port:', port),
          const SizedBox(height: 8),
          _buildRow('Status:', status, color: status == 'Connected' ? Colors.green : Colors.grey),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              protocol,
              style: TextStyle(
                color: Colors.grey.withOpacity(0.3),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color, Widget? trailing}) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
