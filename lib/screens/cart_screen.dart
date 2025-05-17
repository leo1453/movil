import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  void _vaciarCarrito(BuildContext context) async {
    if (user != null) {
      final carrito = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('carrito');

      final snapshot = await carrito.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Carrito vaciado')),
      );
    }
  }

  void _eliminarProducto(String docId, BuildContext context) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('carrito')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado')),
      );
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
            icon: Icon(Icons.delete_forever),
            tooltip: 'Vaciar Carrito',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('¿Vaciar carrito?'),
                  content: Text('¿Seguro que quieres eliminar todos los productos del carrito?'),
                  actions: [
                    TextButton(
                      child: Text('Cancelar'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text('Vaciar', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.pop(context);
                        _vaciarCarrito(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: user == null
          ? Center(child: Text('Debes iniciar sesión para ver tu carrito'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
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

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final doc = cartItems[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final imagenUrl = data['imagen'];

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                   child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: (imagenUrl != null && imagenUrl.startsWith('http'))
                                        ? Image.network(
                                            imagenUrl,
                                            fit: BoxFit.contain,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(child: CircularProgressIndicator(strokeWidth: 2));
                                            },
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              color: Colors.grey[300],
                                              alignment: Alignment.center,
                                              child: Icon(Icons.broken_image, size: 30, color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            alignment: Alignment.center,
                                            child: Icon(Icons.broken_image, size: 30, color: Colors.grey),
                                          ),
                                  ),

                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['nombre'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '${data['cantidad']} x ${data['precio']} MXN',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${(data['precio'] ?? 0) * (data['cantidad'] ?? 1)} MXN',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                          fontSize: 14,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline),
                                        color: Colors.redAccent,
                                        iconSize: 24,
                                        tooltip: 'Eliminar del carrito',
                                        onPressed: () => _eliminarProducto(doc.id, context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Total: ${total.toStringAsFixed(2)} MXN',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
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
                                  builder: (context) => PaymentScreen(cartProducts: cartProducts),
                                ),
                              );
                            },
                            child: Text(
                              'Proceder al pago',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
