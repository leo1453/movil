import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  OrderDetailScreen({required this.orderData});

  @override
  Widget build(BuildContext context) {
    final productos = orderData['productos'] ?? [];
    final direccion = orderData['direccion'] ?? {};
    final metodoPago = orderData['metodoPago'] ?? 'No especificado';
    final total = orderData['total'] ?? 0;
    final fecha = (orderData['fecha'] as Timestamp).toDate();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Detalle del pedido',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Fecha del pedido
            _buildSectionTitle('Fecha del pedido'),
            Text(
              '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),

            // Productos
            _buildSectionTitle('Productos'),
            SizedBox(height: 8),
            ...productos.map<Widget>((p) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      p['imagen'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.broken_image),
                    ),
                  ),
                  title: Text(
                    p['nombre'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Cantidad: ${p['cantidad']}'),
                  trailing: Text(
                    '${p['precio']} MXN',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 24),

            // Total
            _buildSectionTitle('Total del pedido'),
            Text(
              '${total.toStringAsFixed(2)} MXN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 24),

            // Método de pago
            _buildSectionTitle('Método de pago'),
            Text(
              metodoPago,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),

            // Dirección de envío
            _buildSectionTitle('Dirección de envío'),
            Card(
              margin: EdgeInsets.only(top: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      direccion['nombre'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      direccion['direccion'] ?? '',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${direccion['ciudad'] ?? ''}, CP: ${direccion['codigoPostal'] ?? ''}',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tel: ${direccion['telefono'] ?? ''}',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }
}
