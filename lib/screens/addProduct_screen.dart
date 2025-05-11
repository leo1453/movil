import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? existingData;

  AddProductScreen({this.productId, this.existingData});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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

  @override
  void initState() {
    super.initState();
    final data = widget.existingData;
    if (data != null) {
      _nombreController.text = data['nombre'] ?? '';
      _descripcionController.text = data['descripcion'] ?? '';
      _precioController.text = data['precio']?.toString() ?? '';
      _stockController.text = data['stock']?.toString() ?? '';
      final imgs = data['imagenes'] as List<dynamic>? ?? [];
      _imagen1Controller.text = imgs.length > 0 ? imgs[0] : '';
      _imagen2Controller.text = imgs.length > 1 ? imgs[1] : '';
      _imagen3Controller.text = imgs.length > 2 ? imgs[2] : '';
      _marcaController.text = data['marca'] ?? '';
      _modeloController.text = data['modelo'] ?? '';
      _materialController.text = data['material'] ?? '';
      _colorController.text = data['color'] ?? '';
      _dimensionesController.text = data['dimensiones'] ?? '';
      _pesoController.text = data['peso'] ?? '';
      _tiempoEntregaController.text = data['tiempoEntrega'] ?? '';
      _selectedCategory = data['categoria'];
      _selectedCondition = data['condicion'];
      _selectedWarranty = data['garantia'];
    }
  }

  void _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
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
    };

    try {
      final col = FirebaseFirestore.instance.collection('productos');
      if (widget.productId != null) {
        // Actualizar producto existente
        await col.doc(widget.productId).update(payload);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto actualizado exitosamente')),
        );
      } else {
        // Crear nuevo producto
        payload['ownerId'] = FirebaseAuth.instance.currentUser!.uid;
        await col.add(payload);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto agregado exitosamente')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Producto' : 'Agregar Producto',
          style: TextStyle(color: Colors.white),
        ),
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
              _buildTextField(
                _precioController,
                'Precio',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                _stockController,
                'Stock disponible',
                keyboardType: TextInputType.number,
              ),
              _buildDropdownField(
                label: 'Categoría',
                value: _selectedCategory,
                items: ['Anime', 'Videojuegos', 'Cómics', 'Películas'],
                onChanged: (value) => setState(() => _selectedCategory = value),
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
              _buildTextField(
                _dimensionesController,
                'Dimensiones (alto x ancho x profundidad)',
              ),
              _buildTextField(_pesoController, 'Peso (kg)'),
              Divider(height: 32),

              _buildSectionTitle('Detalles adicionales'),
              _buildDropdownField(
                label: 'Condición',
                value: _selectedCondition,
                items: ['Nuevo', 'Usado'],
                onChanged: (value) => setState(() => _selectedCondition = value),
              ),
              _buildDropdownField(
                label: 'Garantía',
                value: _selectedWarranty,
                items: ['Sí', 'No'],
                onChanged: (value) => setState(() => _selectedWarranty = value),
              ),
              _buildTextField(
                _tiempoEntregaController,
                'Tiempo estimado de entrega (días)',
              ),

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
                child: Text(
                  isEditing ? 'Actualizar Producto' : 'Guardar Producto',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
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