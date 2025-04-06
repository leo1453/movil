import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carrito de Compras'), backgroundColor: Colors.deepPurple),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          ListTile(
            leading: Icon(Icons.shopping_bag, color: Colors.deepPurple),
            title: Text('Figura Anime'),
            subtitle: Text('1 x 1500 MXN'),
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag, color: Colors.deepPurple),
            title: Text('Figura Videojuego'),
            subtitle: Text('1 x 2200 MXN'),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total: 3700 MXN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () {},
              child: Text('Proceder al pago'),
            ),
          ),
        ],
      ),
    );
  }
}