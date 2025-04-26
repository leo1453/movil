import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/screens/addProduct_screen.dart';
import '../widgets/product_card.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> favoriteProducts = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

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
        title: Text('Figuras Coleccionables', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen()));
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
                suffixIcon: searchQuery.isNotEmpty
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              stream: FirebaseFirestore.instance.collection('productos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final productos = snapshot.data!.docs;

                final filteredProducts = productos.where((producto) {
                  final data = producto.data() as Map<String, dynamic>;
                  final nombre = (data['nombre'] ?? '').toString().toLowerCase();
                  return nombre.contains(searchQuery);
                }).toList();

                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final producto = filteredProducts[index];
                    final data = producto.data() as Map<String, dynamic>;

                    // 🛠️ AQUÍ: se obtiene la imagen correctamente
                    final imagenUrl = _obtenerImagenPrincipal(data);

                    return ProductCard(
                      title: data['nombre'] ?? '',
                      price: '${data['precio']} MXN',
                      image: imagenUrl,
                      isFavorite: isFavorite(data),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(productData: data),
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
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductScreen()));
        },
      ),
    );
  }

  String _obtenerImagenPrincipal(Map<String, dynamic> data) {
    if (data['imagenes'] != null && data['imagenes'] is List && data['imagenes'].isNotEmpty) {
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
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.category, color: Colors.deepPurple),
            title: Text('Categorías', style: TextStyle(color: Colors.deepPurple)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen())),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.deepPurple),
            title: Text('Carrito', style: TextStyle(color: Colors.deepPurple)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen())),
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.deepPurple),
            title: Text('Favoritos', style: TextStyle(color: Colors.deepPurple)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoritesScreen(favoriteProducts: favoriteProducts)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.history, color: Colors.deepPurple),
            title: Text('Historial de pedidos', style: TextStyle(color: Colors.deepPurple)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderHistoryScreen())),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.deepPurple),
            title: Text('Perfil de usuario', style: TextStyle(color: Colors.deepPurple)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
          ),
          Spacer(),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.deepPurple),
            title: Text('Cerrar sesión', style: TextStyle(color: Colors.deepPurple)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
