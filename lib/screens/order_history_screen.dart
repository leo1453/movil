import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de pedidos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          user == null
              ? Center(child: Text('Debes iniciar sesión para ver tus pedidos'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(user!.uid)
                        .collection('pedidos')
                        .orderBy('fecha', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No tienes pedidos aún.'));
                  }

                  final orders = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final orderData =
                          orders[index].data() as Map<String, dynamic>;
                      final productos = orderData['productos'] ?? [];
                      final total = orderData['total'] ?? 0;
                      final fecha = (orderData['fecha'] as Timestamp).toDate();

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha: ${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Productos:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ...List.generate(productos.length, (i) {
                                final producto = productos[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.deepPurple,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${producto['nombre']} (x${producto['cantidad']})',
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              Divider(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Total: ${total.toStringAsFixed(2)} MXN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ],
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
