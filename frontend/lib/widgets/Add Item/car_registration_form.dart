

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/car.dart';
import '../../services/Add Items/car_service.dart';


class CarRegistrationForm extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onSubmit;
  const CarRegistrationForm({super.key, this.onSubmit});

  @override
  State<CarRegistrationForm> createState() => _CarRegistrationFormState();
}

class _CarRegistrationFormState extends State<CarRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _dailyRateCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  final _picker = ImagePicker();
  final _carService = CarService();

  XFile? _imageFront;
  XFile? _imageRear;
  XFile? _imageInterior;
  PlatformFile? _registrationDoc;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _dailyRateCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(Function(XFile) setter) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => setter(picked));
  }

  Future<void> _pickDocument() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (res != null) setState(() => _registrationDoc = res.files.first);
  }

  bool _validate() {
    if (!_formKey.currentState!.validate()) return false;
    if (_imageFront == null || _imageRear == null || _imageInterior == null) {
      _snack('Debe seleccionar las 3 imágenes');
      return false;
    }
    if (_registrationDoc == null) {
      _snack('Debe adjuntar el documento de registro');
      return false;
    }
    return true;
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final tempCar = Car(
        make: _makeCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        year: int.parse(_yearCtrl.text.trim()),
        dailyRate: _dailyRateCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        imageFront: Uri.parse(''),
        imageRear: Uri.parse(''),
        imageInterior: Uri.parse(''),
        registrationDocument: Uri.parse(''),
        isActive: true,
      );

      final created = await _carService.registerCar(
        car: tempCar,
        imageFrontPath: _imageFront!.path,
        imageRearPath: _imageRear!.path,
        imageInteriorPath: _imageInterior!.path,
        registrationDocumentPath: _registrationDoc!.path!,
      );

      _snack('Auto registrado con éxito');
      widget.onSubmit?.call(created.toJson());

      _formKey.currentState!.reset();
      setState(() {
        _imageFront = _imageRear = _imageInterior = null;
        _registrationDoc = null;
      });
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _imageTile({required String label, required XFile? file, required VoidCallback onPick}) {
    return ListTile(
      leading: file == null ? const Icon(Icons.image) : Image.file(
        // ignore: deprecated_member_use_from_same_package
        File(file.path),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
      title: Text(label),
      trailing: TextButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.upload_file),
        label: Text(file == null ? 'Elegir' : 'Cambiar'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isSubmitting,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _makeCtrl,
              decoration: const InputDecoration(labelText: 'Marca'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modelCtrl,
              decoration: const InputDecoration(labelText: 'Modelo'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearCtrl,
              decoration: const InputDecoration(labelText: 'Año'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                final year = int.tryParse(v);
                if (year == null || year < 1900) return 'Año inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dailyRateCtrl,
              decoration: const InputDecoration(labelText: 'Tarifa diaria (Bs)'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            const Text('Imágenes', style: TextStyle(fontWeight: FontWeight.bold)),
            _imageTile(
              label: 'Frontal',
              file: _imageFront,
              onPick: () => _pickImage((x) => _imageFront = x),
            ),
            _imageTile(
              label: 'Posterior',
              file: _imageRear,
              onPick: () => _pickImage((x) => _imageRear = x),
            ),
            _imageTile(
              label: 'Interior',
              file: _imageInterior,
              onPick: () => _pickImage((x) => _imageInterior = x),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Documento de registro'),
              subtitle: Text(_registrationDoc?.name ?? 'Ninguno seleccionado'),
              trailing: TextButton.icon(
                onPressed: _pickDocument,
                icon: const Icon(Icons.upload_file),
                label: Text(_registrationDoc == null ? 'Elegir' : 'Cambiar'),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.cloud_upload),
                label: _isSubmitting
                    ? const Text('Enviando...')
                    : const Text('Registrar Auto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
