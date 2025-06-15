// lib/widgets/car_edit_modal.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../models/Main Screen/carAvailable.dart';
import '../../services/my items/my_cars_service.dart';
import '../../services/image_service.dart';
import 'car_edit_modal_view.dart';

class CarEditModal extends StatefulWidget {
  final CarAvailable car;
  const CarEditModal({super.key, required this.car});

  static Future<CarAvailable?> show(BuildContext context, CarAvailable car) {
    return showDialog<CarAvailable?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: CarEditModal(car: car),
      ),
    );
  }

  @override
  State<CarEditModal> createState() => _CarEditModalState();
}

class _CarEditModalState extends State<CarEditModal> {
  // -------- Text Ctrls --------
  late final _make     = TextEditingController(text: widget.car.make);
  late final _model    = TextEditingController(text: widget.car.model);
  late final _year     = TextEditingController(text: widget.car.year.toString());
  late final _desc     = TextEditingController(text: widget.car.description);
  late final _rate     = TextEditingController(text: widget.car.dailyRate);

  // -------- Imágenes (File?) --------
  File? _front;
  File? _rear;
  File? _interior;
  File? _doc;

  bool _loading = false;
  String? _error;

  // ---------- File picker helpers ----------
  Future<void> _pickFile(ValueSetter<File?> setter) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setter(File(result.files.single.path!));
      setState(() {}); // refrescar preview
    }
  }

  // ---------- Guardar ----------
  Future<void> _onSave() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Campos de texto
    final data = <String, String>{
      'make': _make.text.trim(),
      'model': _model.text.trim(),
      'year': (_year.text.trim()),
      'description': _desc.text.trim(),
      'daily_rate': _rate.text.trim(),
      'is_active': 'true', // siempre true
    };

    // Archivos solo si cambian
    final files = <String, String>{};
    if (_front != null)    files['image_front']         = _front!.path;
    if (_rear != null)     files['image_rear']          = _rear!.path;
    if (_interior != null) files['image_interior']      = _interior!.path;
    if (_doc != null)      files['registration_document'] = _doc!.path;

    try {
      final updated = await MyCarsService()
          .updateCar(widget.car.id, data: data, files: files);

      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }


  void _onCancel() => Navigator.of(context).pop(null);

  @override
  Widget build(BuildContext context) {
    return CarEditModalView(
      // texto
      makeCtrl: _make,
      modelCtrl: _model,
      yearCtrl: _year,
      descriptionCtrl: _desc,
      rateCtrl: _rate,
      // previews  (si no hay File, mostramos URL existente)
      frontPreview   : _front?.path   ?? ImageService.getFullImageUrl(widget.car.imageFront.toString()),
      rearPreview    : _rear?.path    ?? ImageService.getFullImageUrl(widget.car.imageRear.toString()),
      interiorPreview: _interior ?.path ?? ImageService.getFullImageUrl(widget.car.imageInterior.toString()),
      docPreviewUrl  : _doc?.path ??
          ImageService.getFullImageUrl(
            widget.car.registrationDocument.toString(),
          ),
      onPickFront    : () => _pickFile((f) => _front = f),
      onPickRear     : () => _pickFile((f) => _rear = f),
      onPickInterior : () => _pickFile((f) => _interior = f),
      onPickDoc      : () => _pickFile((f) => _doc = f),
      // resto
      loading: _loading,
      error  : _error,
      onCancel: _onCancel,
      onSave  : _onSave,
    );
  }
}
