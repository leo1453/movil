import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> _removeFavorite(String nombre) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('favoritos');

      final snapshot = await favRef.where('nombre', isEqualTo: nombre).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  String _obtenerImagenPrincipal(Map<String, dynamic> product) {
    if (product['imagenes'] != null &&
        product['imagenes'] is List &&
        product['imagenes'].isNotEmpty) {
      return product['imagenes'][0];
    } else if (product['imagen'] != null &&
        product['imagen'].toString().isNotEmpty) {
      return product['imagen'];
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mis favoritos'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final favoritosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('favoritos');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Mis favoritos'),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoritosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No tienes productos favoritos todavía.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final imagenUrl = _obtenerImagenPrincipal(data);

              return Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    if (data['id'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Este producto no tiene ID válido')),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productData: data),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['nombre'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6),
                              Text(
                                '${data['precio']} MXN',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.favorite, color: Colors.redAccent),
                          tooltip: 'Eliminar de favoritos',
                          onPressed: () async {
                            await _removeFavorite(data['nombre']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Producto eliminado de favoritos')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
