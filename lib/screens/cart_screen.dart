import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  void _vaciarCarrito() async {
    if (user != null) {
      final carrito = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('carrito');

      final snapshot = await carrito.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  void _eliminarProducto(String docId) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('carrito')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carrito de Compras',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _vaciarCarrito();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Carrito vaciado')));
            },
          ),
        ],
      ),
      body:
          user == null
              ? Center(child: Text('Debes iniciar sesión para ver tu carrito'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(user!.uid)
                        .collection('carrito')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Tu carrito está vacío'));
                  }

                  final cartItems = snapshot.data!.docs;
                  double total = 0;
                  List<Map<String, dynamic>> cartProducts = [];

                  for (var item in cartItems) {
                    final data = item.data() as Map<String, dynamic>;
                    total += (data['precio'] ?? 0) * (data['cantidad'] ?? 1);

                    cartProducts.add({
                      'nombre': data['nombre'] ?? '',
                      'precio': data['precio'] ?? 0,
                      'cantidad': data['cantidad'] ?? 1,
                      'imagen': data['imagen'] ?? '',
                    });
                  }

                  return ListView(
                    padding: EdgeInsets.all(8),
                    children: [
                      ...cartItems.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data['imagen'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Icon(Icons.broken_image),
                              ),
                            ),
                            title: Text(data['nombre'] ?? ''),
                            subtitle: Text(
                              '${data['cantidad'] ?? 1} x ${data['precio'] ?? 0} MXN',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(data['precio'] ?? 0) * (data['cantidad'] ?? 1)} MXN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _eliminarProducto(doc.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Producto eliminado'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Total: ${total.toStringAsFixed(2)} MXN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PaymentScreen(
                                      cartProducts: cartProducts,
                                    ),
                              ),
                            );
                          },
                          child: Text(
                            'Proceder al pago',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }
}
