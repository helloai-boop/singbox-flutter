// ignore_for_file: deprecated_member_use

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: status == 'Connected' 
                ? Colors.green.withOpacity(0.08)
                : Colors.grey.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 4),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Stack(
        alignment: AlignmentGeometry.bottomRight,
        children: [
          Column(
            children: [
              _buildRow('Remark:', remark, isBold: true),
              const SizedBox(height: 12),
              _buildRow('Address:', address),
              const SizedBox(height: 12),
              _buildRow('Port:', port),
              const SizedBox(height: 12),
              _buildRow(
                'Status:',
                status,
                color: status == 'Connected' ? const Color(0xFF27AE60) : Colors.grey,
              ),
            ],
          ),

          Positioned(
            right: -10,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                protocol,
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.15),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    Widget? trailing,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
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
