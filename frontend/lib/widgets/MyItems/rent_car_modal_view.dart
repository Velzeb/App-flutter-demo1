// lib/widgets/rent_car_modal_view.dart

import 'package:flutter/material.dart';

class RentCarModalView extends StatelessWidget {
  final String imageUrl;
  final String message;
  final String? start;
  final String? end;
  final bool loading;
  final String? error;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const RentCarModalView({
    Key? key,
    required this.imageUrl,
    required this.message,
    required this.start,
    required this.end,
    required this.loading,
    required this.error,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Imagen y mensaje
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(imageUrl, height: 140, fit: BoxFit.cover),
        ),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),

        // Fecha inicio
        Row(children: [
          const Icon(Icons.calendar_today, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('Inicio: ${start ?? '--/--/---- --:--'}')),
          OutlinedButton(onPressed: onPickStart, child: const Text('Seleccionar')),
        ]),
        const SizedBox(height: 8),

        // Fecha fin
        Row(children: [
          const Icon(Icons.calendar_today, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('Fin:    ${end ?? '--/--/---- --:--'}')),
          OutlinedButton(onPressed: onPickEnd, child: const Text('Seleccionar')),
        ]),
        const SizedBox(height: 12),

        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(error!, style: const TextStyle(color: Colors.red)),
          ),

        // Botones
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: onCancel, child: const Text('Cancelar')),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: loading ? null : onConfirm,
            child: loading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Confirmar'),
          ),
        ]),
      ]),
    );
  }
}
