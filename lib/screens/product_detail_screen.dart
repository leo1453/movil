import 'package:flutter/material.dart';
import 'cart_screen.dart'; // 👈 Importa tu CartScreen

class ProductDetailScreen extends StatefulWidget {
  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _cartItemCount = 0; // Contador del carrito
  int _quantity = 1; // Cantidad seleccionada por el usuario

  void _addToCart() {
    setState(() {
      _cartItemCount += _quantity;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$_quantity producto(s) agregado(s) al carrito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle del Producto',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  // 👇 Redirección al carrito existente
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
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
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                color: Colors.grey[200],
                height: 300,
                width: double.infinity,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/imagenes/mona1.webp',
                  fit: BoxFit.contain,
                  width: 250,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Título del producto
            Text(
              'Figura de Colección',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            // Precio del producto
            Text(
              'Precio: 1500 MXN',
              style: TextStyle(
                fontSize: 18,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16),

            // Descripción del producto
            Text(
              'Edición especial, material PVC de alta calidad. Año de lanzamiento: 2024.',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 24),

            // Selector de cantidad
            Text(
              'Cantidad:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed:
                      _quantity > 1
                          ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                          : null,
                ),
                Text('$_quantity', style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 24),

            // Botón de agregar al carrito
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _addToCart,
                child: Text(
                  'Agregar al carrito',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
