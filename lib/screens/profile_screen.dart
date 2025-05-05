import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    if (user != null) {
      _emailController.text = user!.email ?? '';

      final snapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user!.uid)
              .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        _nameController.text = data?['nombre'] ?? '';
        _addressController.text = data?['direccion'] ?? '';
        _phoneController.text = data?['telefono'] ?? '';
        _postalCodeController.text = data?['codigoPostal'] ?? '';
        _cityController.text = data?['ciudad'] ?? '';
      }
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate() && user != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .set({
            'nombre': _nameController.text,
            'direccion': _addressController.text,
            'telefono': _phoneController.text,
            'codigoPostal': _postalCodeController.text,
            'ciudad': _cityController.text,
            'email': _emailController.text,
          }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
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
      body:
          user == null
              ? Center(child: Text('Debes iniciar sesión'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
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
                        label: 'Ciudad',
                        controller: _cityController,
                        icon: Icons.location_city,
                      ),
                      buildTextField(
                        label: 'Código Postal',
                        controller: _postalCodeController,
                        icon: Icons.markunread_mailbox,
                        inputType: TextInputType.number,
                        inputFormatters: [LengthLimitingTextInputFormatter(5)],
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 5) {
                            return 'Código postal inválido';
                          }
                          return null;
                        },
                      ),
                      buildTextField(
                        label: 'Teléfono',
                        controller: _phoneController,
                        icon: Icons.phone,
                        inputType: TextInputType.phone,
                        inputFormatters: [LengthLimitingTextInputFormatter(10)],
                        validator: (value) {
                          if (value == null || value.length != 10) {
                            return 'Teléfono inválido';
                          }
                          return null;
                        },
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
}
