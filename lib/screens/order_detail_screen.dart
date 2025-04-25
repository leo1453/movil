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
            // Fecha
            Text(
              'Fecha del pedido:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}',
            ),
            SizedBox(height: 16),

            // Productos
            Text(
              'Productos:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 8),
            ...productos.map<Widget>((p) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      p['imagen'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Icon(Icons.broken_image),
                    ),
                  ),
                  title: Text(p['nombre'] ?? ''),
                  subtitle: Text('Cantidad: ${p['cantidad']}'),
                  trailing: Text('${p['precio']} MXN'),
                ),
              );
            }).toList(),

            Divider(),

            // Total
            SizedBox(height: 8),
            Text(
              'Total:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text('${total.toStringAsFixed(2)} MXN'),
            SizedBox(height: 16),

            // Método de pago
            Text(
              'Método de pago:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text(metodoPago),
            SizedBox(height: 16),

            // Dirección de envío
            Text(
              'Dirección de envío:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text('${direccion['nombre'] ?? ''}'),
            Text('${direccion['direccion'] ?? ''}'),
            Text(
              '${direccion['ciudad'] ?? ''}, CP: ${direccion['codigoPostal'] ?? ''}',
            ),
            Text('Tel: ${direccion['telefono'] ?? ''}'),
          ],
        ),
      ),
    );
  }
}
