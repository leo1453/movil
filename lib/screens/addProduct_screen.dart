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
  final TextEditingController _imagenController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String? _selectedCategory;

  void _guardarProducto() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('productos').add({
          'nombre': _nombreController.text.trim(),
          'descripcion': _descripcionController.text.trim(),
          'precio': double.parse(_precioController.text.trim()),
          'imagen': _imagenController.text.trim(),
          'categoria': _selectedCategory,
          'stock': int.parse(_stockController.text.trim()),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto agregado exitosamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al agregar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre del producto'),
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _precioController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _imagenController,
                decoration: InputDecoration(labelText: 'URL de la Imagen'),
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items:
                    ['Anime', 'Videojuegos', 'Cómics', 'Películas'].map((
                      categoria,
                    ) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator:
                    (value) =>
                        value == null ? 'Selecciona una categoría' : null,
              ),

              SizedBox(height: 8),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Stock disponible'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarProducto,
                child: Text('Guardar Producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
