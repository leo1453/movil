import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartProducts;

  PaymentScreen({required this.cartProducts});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = 'Tarjeta de crédito';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _paypalEmailController = TextEditingController();

  double get totalAmount {
    return widget.cartProducts.fold(
      0,
      (sum, item) => sum + (item['precio'] * item['cantidad']),
    );
  }

  void _confirmPurchase() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Procesando pago...')));

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('Usuario no autenticado');
        }

        final uid = user.uid;
        final orderData = {
          'productos': widget.cartProducts,
          'total': totalAmount,
          'direccion': {
            'nombre': _nameController.text,
            'telefono': _phoneController.text,
            'direccion': _addressController.text,
            'ciudad': _cityController.text,
            'codigoPostal': _postalCodeController.text,
          },
          'metodoPago': _selectedPaymentMethod,
          'fecha': Timestamp.now(),
          'estado': 'Pendiente',
        };

        // Guardar el pedido
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .collection('pedidos')
            .add(orderData);

        // 🔥 Vaciar carrito después de guardar pedido
        final carrito = FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .collection('carrito');

        final snapshot = await carrito.get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        Future.delayed(Duration(seconds: 2), () {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: Text('¡Compra exitosa!'),
                  content: Text('Gracias por tu compra.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Text('Volver al inicio'),
                    ),
                  ],
                ),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildPaymentFields() {
    if (_selectedPaymentMethod == 'Tarjeta de crédito') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextField(
            label: 'Número de tarjeta',
            hint: '**** **** **** ****',
            icon: Icons.credit_card,
            controller: _cardNumberController,
            inputType: TextInputType.number,
          ),
          buildTextField(
            label: 'Fecha de expiración',
            hint: 'MM/AA',
            icon: Icons.date_range,
            controller: _expiryDateController,
            inputType: TextInputType.datetime,
          ),
          buildTextField(
            label: 'CVV',
            hint: 'Ej. 123',
            icon: Icons.lock,
            controller: _cvvController,
            inputType: TextInputType.number,
          ),
        ],
      );
    } else if (_selectedPaymentMethod == 'PayPal') {
      return buildTextField(
        label: 'Correo de PayPal',
        hint: 'usuario@correo.com',
        icon: Icons.email,
        controller: _paypalEmailController,
        inputType: TextInputType.emailAddress,
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proceder al pago', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen de la orden',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      for (var product in widget.cartProducts)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Image.network(
                                product['imagen'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Icon(Icons.broken_image, size: 50),
                              ),
                              SizedBox(width: 10),
                              Expanded(child: Text(product['nombre'])),
                              Text('${product['precio']} MXN'),
                            ],
                          ),
                        ),
                      Divider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: ${totalAmount.toStringAsFixed(2)} MXN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Información de envío',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 8),
              buildTextField(
                label: 'Nombre completo',
                hint: 'Ej. Juan Pérez',
                icon: Icons.person,
                controller: _nameController,
              ),
              buildTextField(
                label: 'Teléfono',
                hint: 'Ej. 1234567890',
                icon: Icons.phone,
                controller: _phoneController,
                inputType: TextInputType.phone,
              ),
              buildTextField(
                label: 'Dirección',
                hint: 'Calle, número, colonia',
                icon: Icons.home,
                controller: _addressController,
              ),
              buildTextField(
                label: 'Ciudad',
                hint: 'Ej. Ciudad de México',
                icon: Icons.location_city,
                controller: _cityController,
              ),
              buildTextField(
                label: 'Código Postal',
                hint: 'Ej. 01234',
                icon: Icons.markunread_mailbox,
                controller: _postalCodeController,
                inputType: TextInputType.number,
              ),
              Text(
                'Método de pago',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                items:
                    ['Tarjeta de crédito', 'PayPal']
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              buildPaymentFields(),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _confirmPurchase,
                  child: Text(
                    'Confirmar compra',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
