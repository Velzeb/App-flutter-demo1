// lib/widgets/parking_edit_modal.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/Main Screen/parkingAvailable.dart';
import '../../services/image_service.dart';
import '../../services/my items/my_parking_service.dart';
import 'parking_edit_modal_view.dart';

class ParkingEditModal extends StatefulWidget {
  final ParkingAvailable parking;
  const ParkingEditModal({Key? key, required this.parking}) : super(key: key);

  /// Abre el modal y devuelve el [ParkingAvailable] actualizado o null si se cancela
  static Future<ParkingAvailable?> show(
      BuildContext context, ParkingAvailable parking) {
    return showDialog<ParkingAvailable?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ParkingEditModal(parking: parking),
      ),
    );
  }

  @override
  State<ParkingEditModal> createState() => _ParkingEditModalState();
}

class _ParkingEditModalState extends State<ParkingEditModal> {
  // Controllers para campos de texto
  late final _nameCtrl    = TextEditingController(text: widget.parking.name);
  late final _addressCtrl = TextEditingController(text: widget.parking.address);
  late final _descCtrl    = TextEditingController(text: widget.parking.description);
  late final _rateCtrl    = TextEditingController(text: widget.parking.hourlyRate);

  // Imagen (File?)
  File? _imageFile;

  bool _loading = false;
  String? _error;

  final _service = MyParkingsService();

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _imageFile = File(result.files.single.path!));
    }
  }

  Future<void> _onSave() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Texto
    final data = <String, String>{
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'hourly_rate': _rateCtrl.text.trim(),
      'is_active': 'true', // fijo
    };

    // Archivos (solo si cambió)
    final files = <String, String>{};
    if (_imageFile != null) files['image'] = _imageFile!.path;

    try {
      final updated = await _service.updateCar(
        widget.parking.id,
        data: data,
        files: files,
      );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onCancel() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final previewUrl = widget.parking.image.toString();
    return ParkingEditModalView(
      nameCtrl: _nameCtrl,
      addressCtrl: _addressCtrl,
      descriptionCtrl: _descCtrl,
      rateCtrl: _rateCtrl,
      imagePreview: _imageFile?.path ??
          ImageService.getFullImageUrl(previewUrl),
      onPickImage: _pickImage,
      loading: _loading,
      error: _error,
      onCancel: _onCancel,
      onSave: _onSave,
    );
  }
}
