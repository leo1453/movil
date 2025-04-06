import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Figuras Coleccionables'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(8),
        childAspectRatio: 0.75,
        children: [
          ProductCard(
            title: 'Figura Anime',
            price: '1500 MXN',
            image: 'assets/imagenes/mona1.webp',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductDetailScreen()),
              );
            },
          ),
          ProductCard(
            title: 'Figura Videojuego',
            price: '2200 MXN',
            image: 'assets/imagenes/videojuego.webp',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductDetailScreen()),
              );
            },
          ),
          // Puedes seguir agregando más productos aquí
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text('Categorías'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Carrito'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
