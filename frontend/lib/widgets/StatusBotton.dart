import 'package:flutter/material.dart';

class StatusBotton extends StatelessWidget {
  final bool disponible;
  const StatusBotton({super.key, required this.disponible});

  @override
  Widget build(BuildContext context) {
    final statusText = disponible ? 'Disponible' : 'Rentado';
    final color = disponible ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
