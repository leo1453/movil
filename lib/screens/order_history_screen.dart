import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orders = [
    {
      'date': '08/04/2025',
      'products': ['Figura Anime', 'Figura Videojuego'],
      'total': 3700,
    },
    {
      'date': '02/04/2025',
      'products': ['Figura Anime'],
      'total': 1500,
    },
    {
      'date': '25/03/2025',
      'products': ['Figura Videojuego'],
      'total': 2200,
    },
  ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
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
                    'Fecha: ${order['date']}',
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
                  ...order['products'].map<Widget>((product) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 16, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(product),
                        ],
                      ),
                    );
                  }).toList(),
                  Divider(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: ${order['total']} MXN',
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
      ),
    );
  }
}