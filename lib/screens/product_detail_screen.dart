import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle del Producto'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                width: 250, // Opcional: controlas máximo ancho
              ),
            ),
          ),
            SizedBox(height: 16),
            Text('Figura de Colección', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Edición especial, material PVC de alta calidad. Año de lanzamiento: 2024.'),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () {},
              child: Text(
              'Agregar al carrito',
              style: TextStyle(color: Colors.black),
            ),
            )
          ],
        ),
      ),
    );
  }
}