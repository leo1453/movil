import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favSnapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .collection('favoritos')
              .get();

      List<Map<String, dynamic>> favoritos =
          favSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      setState(() {
        favoriteProducts = favoritos;
      });
    }
  }

  void toggleFavorite(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('favoritos');

    final exists = favoriteProducts.any(
      (p) => p['nombre'] == product['nombre'],
    );
    final productWithId = Map<String, dynamic>.from(product);

    if (!productWithId.containsKey('id') ||
        productWithId['id'].toString().isEmpty) {
      productWithId['id'] = product['id'] ?? product['productId'] ?? '';
    }

    if (exists) {
      final snapshot =
          await favRef.where('nombre', isEqualTo: product['nombre']).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        favoriteProducts.removeWhere((p) => p['nombre'] == product['nombre']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado de favoritos')),
      );
    } else {
      await favRef.add(productWithId);

      setState(() {
        favoriteProducts.add(productWithId);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Producto añadido a favoritos')));
    }
  }

  bool isFavorite(Map<String, dynamic> product) {
    return favoriteProducts.any((p) => p['nombre'] == product['nombre']);
  }

  Future<void> _addProductToCart(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('carrito')
          .add({
            'nombre': product['nombre'],
            'precio': product['precio'],
            'imagen': _obtenerImagenPrincipal(product),
            'cantidad': 1,
            'fechaAgregado': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Producto agregado al carrito')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoriaSeleccionada,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('productos')
                .where('categoria', isEqualTo: widget.categoriaSeleccionada)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay productos en esta categoría.'));
          }

          final productos = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.56,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              final data = producto.data() as Map<String, dynamic>;

              final productMap = {'id': producto.id, ...data};

              final imagenUrl = _obtenerImagenPrincipal(productMap);

              return ProductCard(
                title: (data['nombre'] ?? 'Producto').toString(),
                price: '${data['precio'] ?? 0} MXN',
                image: imagenUrl,
                isFavorite: isFavorite(productMap),
                productId: producto.id,
                stock: data['stock'] ?? 0, // ✅ Línea clave
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProductDetailScreen(productData: productMap),
                    ),
                  );
                },
                onFavoriteToggle: () {
                  toggleFavorite(productMap);
                },
                onAddToCart: () => _addProductToCart(productMap),
              );
            },
          );
        },
      ),
    );
  }

  String _obtenerImagenPrincipal(Map<String, dynamic> data) {
    if (data['imagenes'] != null &&
        data['imagenes'] is List &&
        data['imagenes'].isNotEmpty) {
      return data['imagenes'][0];
    } else if (data['imagen'] != null && data['imagen'].toString().isNotEmpty) {
      return data['imagen'];
    } else {
      return '';
    }
  }
}
