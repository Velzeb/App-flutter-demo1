// lib/widgets/car_edit_modal_view.dart
import 'package:flutter/material.dart';
import 'dart:io';

class CarEditModalView extends StatelessWidget {
  const CarEditModalView({
    super.key,
    required this.makeCtrl,
    required this.modelCtrl,
    required this.yearCtrl,
    required this.descriptionCtrl,
    required this.rateCtrl,
    required this.frontPreview,
    required this.rearPreview,
    required this.interiorPreview,
    required this.docPreviewUrl,
    required this.onPickFront,
    required this.onPickRear,
    required this.onPickInterior,
    required this.onPickDoc,
    required this.loading,
    required this.error,
    required this.onCancel,
    required this.onSave,
  });

  final TextEditingController makeCtrl;
  final TextEditingController modelCtrl;
  final TextEditingController yearCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController rateCtrl;

  // previews (pueden ser File o ImageProvider / String URL)
  final String? frontPreview;
  final String? rearPreview;
  final String? interiorPreview;
  final String docPreviewUrl;

  // pickers
  final VoidCallback onPickFront;
  final VoidCallback onPickRear;
  final VoidCallback onPickInterior;
  final VoidCallback onPickDoc;

  final bool loading;
  final String? error;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  // helper para mostrar File/ImageProvider


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Editar Auto', style: Theme.of(context).textTheme.titleLarge),

          const SizedBox(height: 12),
          TextField(controller: makeCtrl, decoration: const InputDecoration(labelText: 'Marca')),
          TextField(controller: modelCtrl, decoration: const InputDecoration(labelText: 'Modelo')),
          TextField(controller: yearCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Año')),
          TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tarifa diaria (Bs)')),
          TextField(controller: descriptionCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Descripción')),

          const SizedBox(height: 8),
          // ----- Imágenes -----
          _ImageRow(label: 'Frontal', preview: Image.network(frontPreview!, height: 90, fit: BoxFit.cover),  onPick: onPickFront),
          _ImageRow(label: 'Trasera',  preview: Image.network(rearPreview!, height: 90, fit: BoxFit.cover),  onPick: onPickFront),
          _ImageRow(label: 'Interior', preview: Image.network(interiorPreview!, height: 90, fit: BoxFit.cover),  onPick: onPickFront),
          _ImageRow(
            label: 'Documento',
            preview: Image.network(docPreviewUrl, height: 90, fit: BoxFit.cover),
            onPick: onPickDoc,
          ),

          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: const Text('Cancelar')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: loading ? null : onSave,
                child: loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageRow extends StatelessWidget {
  final String label;
  final Widget preview;
  final VoidCallback onPick;
  const _ImageRow({
    required this.label,
    required this.preview,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label)),
          Expanded(child: preview),
          IconButton(icon: const Icon(Icons.edit), onPressed: onPick),
        ],
      ),
    );
  }
}
