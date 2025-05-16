import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/screens/addProduct_screen.dart';
import '../widgets/product_card.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'MisProductosScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> favoriteProducts = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartItemCount();
    _loadFavorites();
  }

  Future<void> _loadCartItemCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .collection('carrito')
              .get();
      setState(() {
        _cartItemCount = snapshot.docs.length;
      });
    }
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

      List<Map<String, dynamic>> actualizados = [];

      for (var doc in favSnapshot.docs) {
        final data = doc.data();

        if (data.containsKey('id') && data['id'].toString().isNotEmpty) {
          actualizados.add(data);
          continue;
        }

        final resultado =
            await FirebaseFirestore.instance
                .collection('productos')
                .where('nombre', isEqualTo: data['nombre'])
                .limit(1)
                .get();

        if (resultado.docs.isNotEmpty) {
          final productoOriginal = resultado.docs.first;
          final newData = {'id': productoOriginal.id, ...data};
          await doc.reference.set(newData);
          actualizados.add(newData);
        } else {
          actualizados.add(data);
        }
      }

      setState(() {
        favoriteProducts = actualizados;
      });
    }
  }

  void _incrementCartCount() {
    setState(() {
      _cartItemCount++;
    });
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
      productWithId['id'] = product['productId'] ?? product['id'] ?? '';
    }

    if (exists) {
      await favRef.where('nombre', isEqualTo: product['nombre']).get().then((
        snapshot,
      ) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      setState(() {
        favoriteProducts.removeWhere((p) => p['nombre'] == product['nombre']);
      });
    } else {
      await favRef.add(productWithId);
      setState(() {
        favoriteProducts.add(productWithId);
      });
    }
  }

  bool isFavorite(Map<String, dynamic> product) {
    return favoriteProducts.any((p) => p['nombre'] == product['nombre']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Figurarte', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            tooltip: 'Agregar producto',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddProductScreen()),
              );
              await _loadFavorites(); // opcional: recarga favoritos al volver
            },
          ),
    IconButton(
          icon: Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CartScreen()),
            );
            // si quieres, puedes seguir recargando el conteo internamente,
            // pero no se mostrará en UI
            await _loadCartItemCount();
          },
        ),

        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: Icon(Icons.search),
                suffixIcon:
                    searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              searchQuery = '';
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('productos')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final productos = snapshot.data!.docs;
                final filtered =
                    productos.where((p) {
                      final data = p.data() as Map<String, dynamic>;
                      final nombre =
                          (data['nombre'] ?? '').toString().toLowerCase();
                      return nombre.contains(searchQuery);
                    }).toList();

                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.56,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final productMap = {'id': doc.id, ...data};
                    final image = _obtenerImagenPrincipal(productMap);

                    return ProductCard(
                      title: productMap['nombre'] ?? '',
                      price: '${productMap['precio']} MXN',
                      image: image,
                      isFavorite: isFavorite(productMap),
                      productId: doc.id,
                      stock:
                          productMap['stock'] ?? 0, // ✅ ESTA LÍNEA ES LA CLAVE
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ProductDetailScreen(
                                  productData: productMap,
                                ),
                          ),
                        );
                        await _loadFavorites();
                      },
                      onFavoriteToggle: () => toggleFavorite(productMap),
                      onAddToCart: () => _addProductToCart(productMap),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
    );
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

      _incrementCartCount();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Producto agregado al carrito')));
    }
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            'Categorías',
            Icons.category,
            CategoriesScreen(),
          ),
          _buildDrawerItem(
            context,
            'Carrito',
            Icons.shopping_cart,
            CartScreen(),
          ),
          _buildDrawerItem(
            context,
            'Favoritos',
            Icons.favorite,
            FavoritesScreen(),
          ),
          _buildDrawerItem(
            context,
            'Historial de pedidos',
            Icons.history,
            OrderHistoryScreen(),
          ),
          _buildDrawerItem(
            context,
            'Mis productos',
            Icons.history,
            MisProductosScreen(),
          ),
          _buildDrawerItem(
            context,
            'Perfil de usuario',
            Icons.person,
            ProfileScreen(),
          ),
          Spacer(),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.deepPurple),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.deepPurple),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: TextStyle(color: Colors.deepPurple)),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
        await _loadFavorites(); // 🔄 recarga favoritos al volver
      },
    );
  }
}
