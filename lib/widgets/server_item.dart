import 'package:flutter/material.dart';
import '../models/server_model.dart';

class ServerItem extends StatelessWidget {
  final ServerModel server;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ServerItem({
    super.key,
    required this.server,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: server.isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade50,
                    Colors.white,
                  ],
                )
              : null,
          color: server.isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: server.isSelected
              ? Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 2,
                )
              : Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: server.isSelected
                  ? Colors.blue.withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: server.isSelected ? 20 : 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            if (server.isSelected)
              BoxShadow(
                color: Colors.blue.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 8),
                spreadRadius: -5,
              ),
          ],
        ),
        child: Row(
          children: [
            // Flag
            Container(
              width: 48,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade100,
                    Colors.grey.shade200,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                server.flag,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    server.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: server.isSelected ? Colors.blue.shade900 : Colors.black87,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          server.type,
                          style: const TextStyle(
                            color: Color(0xFF27AE60),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          server.address,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete button
            if (server.isSelected)
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                  onPressed: onDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
