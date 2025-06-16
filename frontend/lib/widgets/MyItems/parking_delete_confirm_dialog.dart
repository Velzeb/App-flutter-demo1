
import 'package:flutter/material.dart';
import '../../models/Main Screen/parkingAvailable.dart';

class ParkingDeleteConfirmDialog {
  static Future<bool?> show(BuildContext context, ParkingAvailable parking) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar auto'),
        content: Text(
            '¿Estás seguro de eliminar "${parking.name}"? '
                'Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
