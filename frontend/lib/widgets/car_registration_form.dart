import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class CarRegistrationForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const CarRegistrationForm({super.key, required this.onSubmit});

  @override
  State<CarRegistrationForm> createState() => _CarRegistrationFormState();
}

class _CarRegistrationFormState extends State<CarRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dailyRateController = TextEditingController();

  XFile? _imageFront;
  XFile? _imageRear;
  XFile? _imageInterior;
  PlatformFile? _registrationDocument;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _dailyRateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int imageType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          switch (imageType) {
            case 1: // Frente
              _imageFront = pickedFile;
              break;
            case 2: // Trasera
              _imageRear = pickedFile;
              break;
            case 3: // Interior
              _imageInterior = pickedFile;
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _registrationDocument = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar documento: $e')),
      );
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    // Validación de imágenes y documentos
    if (_imageFront == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una imagen frontal del vehículo'),
        ),
      );
      return false;
    }

    if (_imageRear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una imagen trasera del vehículo'),
        ),
      );
      return false;
    }

    if (_imageInterior == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe seleccionar una imagen del interior del vehículo',
          ),
        ),
      );
      return false;
    }

    if (_registrationDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe seleccionar el documento de registro del vehículo',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _submit() async {
    if (!_validateForm()) return;

    // Preparar los datos para enviar
    final formData = {
      'make': _makeController.text,
      'model': _modelController.text,
      'year': int.parse(_yearController.text),
      'description': _descriptionController.text,
      'daily_rate': double.parse(_dailyRateController.text),
      'image_front_path': _imageFront!.path,
      'image_rear_path': _imageRear!.path,
      'image_interior_path': _imageInterior!.path,
      'registration_document_path': _registrationDocument!.path!,
    };

    // Enviar al componente padre para procesar
    widget.onSubmit(formData);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Vehículo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Marca
          TextFormField(
            controller: _makeController,
            decoration: const InputDecoration(
              labelText: 'Marca',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.car_rental),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la marca';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Modelo
          TextFormField(
            controller: _modelController,
            decoration: const InputDecoration(
              labelText: 'Modelo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.model_training),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el modelo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Año
          TextFormField(
            controller: _yearController,
            decoration: const InputDecoration(
              labelText: 'Año',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el año';
              }

              final year = int.tryParse(value);
              if (year == null) {
                return 'Ingrese un año válido';
              }

              if (year < 1900 || year > 2030) {
                return 'Ingrese un año entre 1900 y 2030';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),

          // Descripción
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Tarifa diaria
          TextFormField(
            controller: _dailyRateController,
            decoration: const InputDecoration(
              labelText: 'Tarifa diaria (USD)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la tarifa diaria';
              }

              final rate = double.tryParse(value);
              if (rate == null || rate <= 0) {
                return 'Ingrese una tarifa válida mayor a 0';
              }

              return null;
            },
          ),
          const SizedBox(height: 24),

          // Sección de imágenes
          const Text(
            'Fotos del Vehículo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Imagen frontal
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(1),
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Foto Frontal'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _imageFront != null
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
          const SizedBox(height: 12),

          // Imagen trasera
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(2),
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Foto Trasera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _imageRear != null
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
          const SizedBox(height: 12),

          // Imagen interior
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(3),
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Foto Interior'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _imageInterior != null
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
          const SizedBox(height: 24),

          // Documento de registro
          const Text(
            'Documento de Registro',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Subir documento de registro'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _registrationDocument != null
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
          if (_registrationDocument != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Archivo: ${_registrationDocument!.name}'),
            ),

          const SizedBox(height: 32),

          // Botón de registro
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'REGISTRAR AUTO',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
