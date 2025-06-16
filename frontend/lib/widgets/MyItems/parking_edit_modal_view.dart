// lib/widgets/parking_edit_modal_view.dart

import 'dart:io';

import 'package:flutter/material.dart';

class ParkingEditModalView extends StatelessWidget {
  const ParkingEditModalView({
    Key? key,
    required this.nameCtrl,
    required this.addressCtrl,
    required this.descriptionCtrl,
    required this.rateCtrl,
    required this.imagePreview,
    required this.onPickImage,
    required this.loading,
    required this.error,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);

  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController rateCtrl;

  /// Ruta local del archivo o URL completa
  final String imagePreview;

  final VoidCallback onPickImage;
  final bool loading;
  final String? error;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  Widget _buildPreview() {
    if (imagePreview.startsWith('http')) {
      return Image.network(imagePreview, height: 120, fit: BoxFit.cover);
    } else {
      final file = File(imagePreview);
      return Image.file(file, height: 120, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Editar Parqueo',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),

          // Nombre
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),

          // Dirección
          TextField(
            controller: addressCtrl,
            decoration: const InputDecoration(labelText: 'Dirección'),
          ),
          const SizedBox(height: 12),

          // Descripción
          TextField(
            controller: descriptionCtrl,
            decoration: const InputDecoration(labelText: 'Descripción'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),

          // Tarifa
          TextField(
            controller: rateCtrl,
            decoration:
            const InputDecoration(labelText: 'Tarifa por hora (Bs)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Imagen
          Text('Imagen', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          _buildPreview(),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onPickImage,
              icon: const Icon(Icons.edit),
              tooltip: 'Cambiar imagen',
            ),
          ),
          const SizedBox(height: 12),

          // Error
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
              Text(error!, style: const TextStyle(color: Colors.redAccent)),
            ),

          // Botones
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: const Text('Cancelar')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: loading ? null : onSave,
                child: loading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
