import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controladores para los campos de texto
  final _nameController = TextEditingController(text: "mi nombre");
  final _emailController = TextEditingController(text: "@correo.com");
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController(text: "Av. Siempre Viva 123");
  final _insuranceController = TextEditingController(text: "123456789");

  // Estado para manejar la visibilidad de los campos
  bool _isRentingActivated = false;
  bool _isPasswordVisible = false;
  bool _isInsuranceVisible = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se destruye
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil",
          style: TextStyle(
              color: Colors.white,
              fontWeight:FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Información de Cuenta",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blueAccent,

                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: "Editar Nombre",
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: "Correo Electrónico",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _passwordController,
                  label: "Nueva Contraseña",
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: "Confirmar Contraseña",
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildActivationSection(),
                if (_isRentingActivated) _buildRentingForm(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Lógica para guardar los datos del perfil
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil actualizado')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Guardar Cambios",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets Reutilizables ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, introduce tu $label';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (controller == _confirmPasswordController) {
          if (value != _passwordController.text) {
            return 'Las contraseñas no coinciden';
          }
        }
        return null;
      },
    );
  }

  Widget _buildActivationSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            "Activar mi cuenta para rentar autos",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          value: _isRentingActivated,
          onChanged: (bool value) {
            setState(() {
              _isRentingActivated = value;
            });
          },
          secondary: Icon(
            _isRentingActivated ? Icons.lock_open : Icons.lock,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRentingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        _buildSectionTitle("Editar informacion para Rentar"),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: "Dirección",
          icon: Icons.home,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _insuranceController,
          obscureText: !_isInsuranceVisible,
          decoration: InputDecoration(
            labelText: "Número de Seguro",
            prefixIcon: const Icon(Icons.shield),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isInsuranceVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isInsuranceVisible = !_isInsuranceVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (_isRentingActivated && (value == null || value.isEmpty)) {
              return 'Este campo es obligatorio para rentar';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildImageUploader(
          label: "Foto de mi Seguro",
          onTap: () {
            // Lógica para subir la foto del seguro
          },
        ),
        const SizedBox(height: 24),
        _buildImageUploader(
          label: "Foto de mi Licencia",
          onTap: () {
            // Lógica para subir la foto de la licencia
          },
        ),
      ],
    );
  }

  Widget _buildImageUploader({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload, color: Colors.grey[600], size: 40),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: Colors.grey[800]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}