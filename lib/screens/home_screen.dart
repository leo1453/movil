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
      final favs = favSnapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        favoriteProducts = List<Map<String, dynamic>>.from(favs);
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
      await favRef.add(product);
      setState(() {
        favoriteProducts.add(product);
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
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
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
                    final image = _obtenerImagenPrincipal(data);
                    return ProductCard(
                      title: data['nombre'] ?? '',
                      price: '${data['precio']} MXN',
                      image: image,
                      isFavorite: isFavorite(data),
                      productId: doc.id,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProductDetailScreen(
                                    productData: {'id': doc.id, ...data},
                                  ),
                            ),
                          ),
                      onFavoriteToggle: () => toggleFavorite(data),
                      onAddToCart: () => _addProductToCart(data),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
      ),
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
              width: double.infinity,
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
            FavoritesScreen(favoriteProducts: favoriteProducts),
          ),
          _buildDrawerItem(
            context,
            'Historial de pedidos',
            Icons.history,
            OrderHistoryScreen(),
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
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ),
    );
  }
}
