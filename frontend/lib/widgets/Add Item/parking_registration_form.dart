// lib/widgets/parking_registration_form.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/parking.dart';
import '../../services/Add Items/parking_service.dart';

class ParkingRegistrationForm extends StatefulWidget {
  final void Function(Parking)? onSubmit;
  const ParkingRegistrationForm({Key? key, this.onSubmit}) : super(key: key);

  @override
  State<ParkingRegistrationForm> createState() => _ParkingRegistrationFormState();
}

class _ParkingRegistrationFormState extends State<ParkingRegistrationForm> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _rateCtrl   = TextEditingController();
  final _service    = ParkingService();
  final _picker     = ImagePicker();

  XFile?   _image;
  LatLng?  _position;
  bool     _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) setState(() => _image = file);
  }

  Future<void> _pickLocation() async {
    final result = await showDialog<LatLng>(
      context: context,
      builder: (ctx) {
        LatLng selected = _position ?? const LatLng(0, 0);
        return Scaffold(
          appBar: AppBar(title: const Text('Seleccionar ubicación')),
          body: FlutterMap(
            options: MapOptions(
              initialCenter: selected,
              initialZoom: 13.0,
              onTap: (tapPos, latlng) => setState(() => selected = latlng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: selected,
                    width: 36,
                    height: 36,
                    // En flutter_map 8.1.1 se usa `child` en vez de `builder`
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, null),
                    child: const Text('Cancelar'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, selected),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() => _position = result);
    }
  }


  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  bool _validate() {
    if (!_formKey.currentState!.validate()) return false;
    if (_image == null) {
      _snack('Seleccione una imagen');
      return false;
    }
    if (_position == null) {
      _snack('Seleccione una ubicación');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _submitting = true);

    try {
      final newParking = await _service.registerParking(
        parking: Parking(
          name:       _nameCtrl.text.trim(),
          address:    '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
          description:_descCtrl.text.trim(),
          image:      Uri.parse(''),
          hourlyRate: _rateCtrl.text.trim(),
          isActive:   true,
        ),
        imagePath: _image!.path,
      );
      _snack('Parqueo registrado');
      widget.onSubmit?.call(newParking);
      _formKey.currentState!.reset();
      setState(() {
        _image = null;
        _position = null;
      });
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _submitting,
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickLocation,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Ubicación'),
              child: Text(
                _position != null
                    ? '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}'
                    : 'Tocar para seleccionar',
                style: TextStyle(color: _position==null ? Colors.grey : null),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descripción'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _rateCtrl,
            decoration: const InputDecoration(labelText: 'Tarifa por hora (Bs)'),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: _image == null
                ? const Icon(Icons.image)
                : Image.file(File(_image!.path), width: 40, height: 40, fit: BoxFit.cover),
            title: const Text('Imagen'),
            trailing: TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Elegir'),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.cloud_upload),
            label: _submitting
                ? const Text('Enviando...')
                : const Text('Registrar Parqueo'),
          ),
        ]),
      ),
    );
  }
}
