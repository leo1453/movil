import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, String>> favoriteProducts = [
    {
      'title': 'Figura Anime',
      'price': '1500 MXN',
      'image': 'assets/imagenes/mona1.webp',
    },
    {
      'title': 'Figura Videojuego',
      'price': '2200 MXN',
      'image': 'assets/imagenes/videojuego.webp',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis favoritos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          favoriteProducts.isEmpty
              ? Center(
                child: Text(
                  'No tienes productos favoritos todavía.',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = favoriteProducts[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          product['image']!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(product['title']!),
                      subtitle: Text(product['price']!),
                      trailing: Icon(Icons.favorite, color: Colors.red),
                    ),
                  );
                },
              ),
    );
  }
}
