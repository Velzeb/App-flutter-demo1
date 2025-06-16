// lib/widgets/car_delete_confirm_dialog.dart
import 'package:flutter/material.dart';
import '../../models/Main Screen/carAvailable.dart';

class CarDeleteConfirmDialog {
  static Future<bool?> show(BuildContext context, CarAvailable car) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar auto'),
        content: Text(
            '¿Estás seguro de eliminar "${car.make} ${car.model} (${car.year})"? '
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
