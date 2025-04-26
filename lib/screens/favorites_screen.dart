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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Producto eliminado de favoritos')),
    );
  }

  String obtenerImagenPrincipal(Map<String, dynamic> product) {
    if (product['imagenes'] != null && product['imagenes'] is List && product['imagenes'].isNotEmpty) {
      return product['imagenes'][0];
    } else if (product['imagen'] != null && product['imagen'].toString().isNotEmpty) {
      return product['imagen'];
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Mis favoritos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: localFavorites.isEmpty
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
                final imagenUrl = obtenerImagenPrincipal(product);

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(productData: product),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Imagen
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[100],
                              child: imagenUrl.isNotEmpty
                                  ? Image.network(
                                      imagenUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                    )
                                  : Center(
                                      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                    ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Información producto
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['nombre'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '${product['precio']} MXN',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botón eliminar favorito
                          IconButton(
                            icon: Icon(Icons.favorite, color: Colors.redAccent),
                            tooltip: 'Eliminar de favoritos',
                            onPressed: () {
                              removeFavorite(product);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
