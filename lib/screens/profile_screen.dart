import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final TextEditingController _nameController = TextEditingController(
    text: 'Juan Pérez',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'juan.perez@example.com',
  );
  final TextEditingController _addressController = TextEditingController(
    text: 'Av. Principal 123, Ciudad de México',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '555-1234-567',
  );

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil actualizado correctamente 🎉')),
      );
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de usuario', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(height: 16),
              buildTextField(
                label: 'Nombre completo',
                controller: _nameController,
                icon: Icons.person,
              ),
              buildTextField(
                label: 'Correo electrónico',
                controller: _emailController,
                icon: Icons.email,
                inputType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su correo';
                  }
                  if (!value.contains('@')) {
                    return 'Ingrese un correo válido';
                  }
                  return null;
                },
              ),
              buildTextField(
                label: 'Dirección',
                controller: _addressController,
                icon: Icons.home,
              ),
              buildTextField(
                label: 'Teléfono',
                controller: _phoneController,
                icon: Icons.phone,
                inputType: TextInputType.phone,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveProfile,
                  icon: Icon(Icons.save, color: Colors.white),
                  label: Text(
                    'Guardar cambios',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> ed3662d3dd25d79a327c2264dc5b9d3303e35403
