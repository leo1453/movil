import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteProducts;

  FavoritesScreen({required this.favoriteProducts});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<Map<String, dynamic>> localFavorites;

  @override
  void initState() {
    super.initState();
    localFavorites = List.from(widget.favoriteProducts);
  }

  void removeFavorite(Map<String, dynamic> product) {
    setState(() {
      localFavorites.removeWhere((p) => p['nombre'] == product['nombre']);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Producto eliminado de favoritos')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis favoritos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          localFavorites.isEmpty
              ? Center(
                child: Text(
                  'No tienes productos favoritos todavía.',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: localFavorites.length,
                itemBuilder: (context, index) {
                  final product = localFavorites[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product['imagen'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                      title: Text(product['nombre'] ?? ''),
                      subtitle: Text('${product['precio']} MXN'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          removeFavorite(product);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProductDetailScreen(productData: product),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
