import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoriaSeleccionada;

  CategoryProductsScreen({required this.categoriaSeleccionada});

  @override
  _CategoryProductsScreenState createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Map<String, dynamic>> favoriteProducts = [];

  void toggleFavorite(Map<String, dynamic> product) {
    setState(() {
      if (isFavorite(product)) {
        favoriteProducts.removeWhere((p) => p['nombre'] == product['nombre']);
      } else {
        favoriteProducts.add(product);
      }
    });
  }

  bool isFavorite(Map<String, dynamic> product) {
    return favoriteProducts.any((p) => p['nombre'] == product['nombre']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoriaSeleccionada),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('productos')
                .where('categoria', isEqualTo: widget.categoriaSeleccionada)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final productos = snapshot.data!.docs;

          if (productos.isEmpty) {
            return Center(child: Text('No hay productos en esta categoría.'));
          }

          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              final data = producto.data() as Map<String, dynamic>;

              return ProductCard(
                title: data['nombre'] ?? '',
                price: '${data['precio']} MXN',
                image: data['imagen'] ?? '',
                isFavorite: isFavorite(data),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductDetailScreen(productData: data),
                    ),
                  );
                },
                onFavoriteToggle: () {
                  toggleFavorite(data);
                },
              );
            },
          );
        },
      ),
    );
  }
}
