import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  ProductDetailScreen({required this.productData});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _cartItemCount = 0;
  int _quantity = 1;
  int _currentImageIndex = 0;
  final List<String> comentarios = [
    '¡Excelente calidad, me encantó!',
    'Muy bonito, llegó rápido.',
    'Lo recomiendo totalmente.',
    'El producto es igual que en la foto.',
    'Me hubiera gustado otro empaque, pero está bien.',
    'Perfecto para regalar.',
    'Atención rápida y buena calidad.',
  ];

  late List<String> comentariosAleatorios;
  final TextEditingController _comentarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    comentariosAleatorios = _obtenerComentariosAleatorios();
  }

  void _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('carrito')
          .add({
        'nombre': widget.productData['nombre'],
        'precio': widget.productData['precio'],
        'imagen': _obtenerImagenPrincipal(widget.productData),
        'cantidad': _quantity,
        'fechaAgregado': FieldValue.serverTimestamp(),
      });

      setState(() {
        _cartItemCount += _quantity;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_quantity producto(s) agregado(s) al carrito')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión para agregar al carrito')),
      );
    }
  }

  void _agregarComentario() {
    final texto = _comentarioController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        comentariosAleatorios.insert(0, texto);
        _comentarioController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productData;
    final List<String> imagenes = _obtenerListaImagenes(product['imagenes'] ?? product['imagen']);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(product['nombre'] ?? 'Producto', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen()));
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('$_cartItemCount', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagenes(imagenes),
            SizedBox(height: 24),
            Text(product['nombre'] ?? 'Producto', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            Row(children: List.generate(5, (index) => Icon(Icons.star, size: 20, color: Colors.amber))),
            SizedBox(height: 8),
            Text('${product['precio']} MXN', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 16),
            Text(product['descripcion'] ?? 'Sin descripción disponible.', style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.4)),
            SizedBox(height: 30),
            _buildSectionTitle('Características'),
            _buildDetailRow('Marca', product['marca']),
            _buildDetailRow('Modelo', product['modelo']),
            _buildDetailRow('Material', product['material']),
            _buildDetailRow('Color', product['color']),
            _buildDetailRow('Dimensiones', product['dimensiones']),
            _buildDetailRow('Peso', product['peso']),
            SizedBox(height: 30),
            _buildSectionTitle('Detalles adicionales'),
            _buildDetailRow('Condición', product['condicion']),
            _buildDetailRow('Garantía', product['garantia']),
            _buildDetailRow('Tiempo estimado de entrega', '${product['tiempoEntrega']} días'),
            SizedBox(height: 30),
            Text('Cantidad:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            _buildCantidadSelector(),
            SizedBox(height: 30),
            _buildAgregarAlCarrito(),
            SizedBox(height: 30),
            Divider(),
            _buildSectionTitle('Opiniones de clientes'),
            ...comentariosAleatorios.map((comentario) => Card(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Icon(Icons.person_outline, color: Colors.deepPurple),
                title: Text(comentario, style: TextStyle(fontSize: 15)),
              ),
            )).toList(),
            SizedBox(height: 20),
            TextField(
              controller: _comentarioController,
              decoration: InputDecoration(
                hintText: 'Escribe tu opinión...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _agregarComentario,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagenes(List<String> imagenes) {
    if (imagenes.isEmpty) {
      return Container(height: 300, alignment: Alignment.center, child: Icon(Icons.broken_image, size: 60, color: Colors.grey));
    }
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: imagenes.length == 1
              ? _buildImagen(imagenes[0])
              : PageView.builder(
                  itemCount: imagenes.length,
                  onPageChanged: (index) => setState(() => _currentImageIndex = index),
                  itemBuilder: (context, index) => _buildImagen(imagenes[index]),
                ),
        ),
        if (imagenes.length > 1)
          SizedBox(height: 12),
        if (imagenes.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imagenes.length, (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: _currentImageIndex == index ? 12 : 8,
              height: _currentImageIndex == index ? 12 : 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _currentImageIndex == index ? Colors.deepPurple : Colors.grey),
            )),
          ),
      ],
    );
  }

  Widget _buildImagen(String url) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.white,
          constraints: BoxConstraints(maxWidth: 250),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 60, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildCantidadSelector() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: CircleBorder(), padding: EdgeInsets.all(12)),
          child: Icon(Icons.remove, size: 20, color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$_quantity', style: TextStyle(fontSize: 18)),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _quantity++),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: CircleBorder(), padding: EdgeInsets.all(12)),
          child: Icon(Icons.add, size: 20, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAgregarAlCarrito() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
        label: Text('Agregar al carrito', style: TextStyle(color: Colors.white, fontSize: 18)),
        onPressed: _addToCart,
      ),
    );
  }

  List<String> _obtenerListaImagenes(dynamic imagenes) {
    if (imagenes is List) {
      return imagenes.whereType<String>().toList();
    } else if (imagenes is String && imagenes.trim().isNotEmpty) {
      return [imagenes];
    } else {
      return [];
    }
  }

  String _obtenerImagenPrincipal(Map<String, dynamic> data) {
    if (data['imagenes'] != null && data['imagenes'] is List && data['imagenes'].isNotEmpty) {
      return data['imagenes'][0];
    } else if (data['imagen'] != null && data['imagen'].toString().isNotEmpty) {
      return data['imagen'];
    } else {
      return '';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || (value is String && value.isEmpty)) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text('$label: $value', style: TextStyle(fontSize: 16)),
    );
  }

  List<String> _obtenerComentariosAleatorios() {
    final random = Random();
    final shuffled = List<String>.from(comentarios)..shuffle(random);
    return shuffled.take(5).toList();
  }
}
