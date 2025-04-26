import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imagen1Controller = TextEditingController();
  final TextEditingController _imagen2Controller = TextEditingController();
  final TextEditingController _imagen3Controller = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _dimensionesController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _tiempoEntregaController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedWarranty;

  void _guardarProducto() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('productos').add({
          'nombre': _nombreController.text.trim(),
          'descripcion': _descripcionController.text.trim(),
          'precio': double.parse(_precioController.text.trim()),
          'categoria': _selectedCategory,
          'stock': int.parse(_stockController.text.trim()),
          'imagenes': [
            _imagen1Controller.text.trim(),
            _imagen2Controller.text.trim(),
            _imagen3Controller.text.trim(),
          ],
          'marca': _marcaController.text.trim(),
          'modelo': _modeloController.text.trim(),
          'material': _materialController.text.trim(),
          'color': _colorController.text.trim(),
          'dimensiones': _dimensionesController.text.trim(),
          'peso': _pesoController.text.trim(),
          'condicion': _selectedCondition,
          'garantia': _selectedWarranty,
          'tiempoEntrega': _tiempoEntregaController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto agregado exitosamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Agregar Producto'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('Información básica'),
              _buildTextField(_nombreController, 'Nombre del producto'),
              _buildTextField(_descripcionController, 'Descripción'),
              _buildTextField(_precioController, 'Precio', keyboardType: TextInputType.number),
              _buildTextField(_stockController, 'Stock disponible', keyboardType: TextInputType.number),
              _buildDropdownField(
                label: 'Categoría',
                value: _selectedCategory,
                items: ['Anime', 'Videojuegos', 'Cómics', 'Películas'],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              Divider(height: 32),

              _buildSectionTitle('Imágenes del producto (URLs)'),
              _buildTextField(_imagen1Controller, 'Imagen 1 (URL)'),
              _buildTextField(_imagen2Controller, 'Imagen 2 (URL)'),
              _buildTextField(_imagen3Controller, 'Imagen 3 (URL)'),
              Divider(height: 32),

              _buildSectionTitle('Características físicas'),
              _buildTextField(_marcaController, 'Marca'),
              _buildTextField(_modeloController, 'Modelo'),
              _buildTextField(_materialController, 'Material'),
              _buildTextField(_colorController, 'Color principal'),
              _buildTextField(_dimensionesController, 'Dimensiones (alto x ancho x profundidad)'),
              _buildTextField(_pesoController, 'Peso (kg)'),
              Divider(height: 32),

              _buildSectionTitle('Detalles adicionales'),
              _buildDropdownField(
                label: 'Condición',
                value: _selectedCondition,
                items: ['Nuevo', 'Usado'],
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value;
                  });
                },
              ),
              _buildDropdownField(
                label: 'Garantía',
                value: _selectedWarranty,
                items: ['Sí', 'No'],
                onChanged: (value) {
                  setState(() {
                    _selectedWarranty = value;
                  });
                },
              ),
              _buildTextField(_tiempoEntregaController, 'Tiempo estimado de entrega (días)'),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarProducto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Guardar Producto', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null ? 'Selecciona una opción' : null,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
