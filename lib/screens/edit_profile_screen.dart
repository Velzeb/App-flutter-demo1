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
                const SizedBox(height: 20),
                _buildActivationSection(),
                if (_isRentingActivated) _buildRentingForm(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil actualizado')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold

                    ),
                  ),
                  child: const Text("Guardar Cambios"),
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

  // Widget para los Textos
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
        prefixIcon: Icon(icon, color: Colors.black87),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black45),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.black87),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, introduce tu $label';
        }
        return null;
      },
    );
  }



  // Widget para los testos con password popo:
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black87),
        prefixIcon: const Icon(Icons.lock, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black45),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.black87,
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
          title: Text(
            _isRentingActivated
                ? "Activaste tu cuenta para rentar autos"
                : "Activar mi cuenta para rentar autos",
            style: TextStyle(
              fontSize: 14,
              color: _isRentingActivated ? Colors.blueAccent : Colors.grey[700],

            ),
          ),
          value: _isRentingActivated,
          onChanged: (bool value) {
            setState(() {
              _isRentingActivated = value;
            });
          },
          activeColor: Colors.blueAccent,            // Thumb activo
          activeTrackColor: Colors.blue[100],  // Pista activa
          inactiveThumbColor: Colors.grey[500], // Thumb inactivo
          inactiveTrackColor: Colors.grey[300], // Pista inactiva
          secondary: Icon(
            _isRentingActivated ? Icons.lock_open : Icons.lock,
            color: _isRentingActivated ? Colors.blueAccent : Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }



  Widget _buildRentingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 20),
        Text(
          "Editar informacion para Rentar",
          style: TextStyle(
            fontSize: 24,
            color: Colors.blueAccent,

          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _addressController,
          label: "Dirección",
          icon: Icons.home,

        ),
        const SizedBox(height: 20),
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
          label: "Foto de mi licencia",
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
        height: 185,
        decoration: BoxDecoration(
          color: Colors.blue[50], // Fondo azul muy suave
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.shade200, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.file_upload_outlined, color: Colors.blue[700], size: 30),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}