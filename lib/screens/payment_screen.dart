import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:proyecto/screens/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartProducts;

  PaymentScreen({required this.cartProducts});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = 'Tarjeta de crédito';

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _paypalEmailController = TextEditingController();

  double get totalAmount {
    return widget.cartProducts.fold(
      0,
      (sum, item) => sum + (item['precio'] * item['cantidad']),
    );
  }

  @override
  void initState() {
    super.initState();
    _precargarDatosUsuario();
  }

  Future<void> _precargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['nombre'] ?? '';
        _phoneController.text = data['telefono'] ?? '';
        _addressController.text = data['direccion'] ?? '';
        _cityController.text = data['ciudad'] ?? '';
        _postalCodeController.text = data['codigoPostal'] ?? '';
      }
    }
  }

  void _confirmPurchase() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Usuario no autenticado');

        final uid = user.uid;

        for (var item in widget.cartProducts) {
          final nombreProducto = item['nombre'];
          final cantidadComprada = item['cantidad'];

          final query =
              await FirebaseFirestore.instance
                  .collection('productos')
                  .where('nombre', isEqualTo: nombreProducto)
                  .get();

          if (query.docs.isEmpty) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Producto no encontrado: $nombreProducto'),
              ),
            );
            return;
          }

          final stockActual = query.docs.first['stock'] ?? 0;
          if (cantidadComprada > stockActual) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Stock insuficiente para "$nombreProducto". Solo hay $stockActual disponibles.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        final cardLast4 =
            _cardNumberController.text.length >= 4
                ? _cardNumberController.text.substring(
                  _cardNumberController.text.length - 4,
                )
                : '';

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
          'tarjetaFinal': cardLast4,
          'fecha': Timestamp.now(),
          'estado': 'Pendiente',
        };

        final userRef = FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid);
        final globalRef = FirebaseFirestore.instance.collection(
          'pedidos_globales',
        );

        await userRef.collection('pedidos').add(orderData);
        await globalRef.add({...orderData, 'uid': uid});

        for (var item in widget.cartProducts) {
          final nombreProducto = item['nombre'];
          final cantidadComprada = item['cantidad'];

          final query =
              await FirebaseFirestore.instance
                  .collection('productos')
                  .where('nombre', isEqualTo: nombreProducto)
                  .get();

          if (query.docs.isNotEmpty) {
            final docRef = query.docs.first.reference;
            final currentStock = query.docs.first['stock'] ?? 0;
            final nuevoStock = (currentStock - cantidadComprada).clamp(
              0,
              currentStock,
            );
            await docRef.update({'stock': nuevoStock});
          }
        }

        final carrito = userRef.collection('carrito');
        final snapshot = await carrito.get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        Navigator.pop(context); 
        await showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text('¡Compra exitosa!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Gracias por tu compra.'),
                    SizedBox(height: 10),
                    ...widget.cartProducts
                        .map((p) => Text('- ${p['nombre']} x${p['cantidad']}'))
                        .toList(),
                    SizedBox(height: 10),
                    Text('Total: \$${totalAmount.toStringAsFixed(2)} MXN'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: Text('Volver al inicio'),
                  ),
                ],
              ),
        );
      } catch (e) {
        Navigator.pop(context);
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty)
                return 'Este campo es obligatorio';
              return null;
            },
        inputFormatters: inputFormatters,
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
        children: [
          buildTextField(
            label: 'Número de tarjeta',
            hint: '**** **** **** ****',
            icon: Icons.credit_card,
            controller: _cardNumberController,
            inputType: TextInputType.number,
            inputFormatters: [LengthLimitingTextInputFormatter(16)],
            validator:
                (v) =>
                    v == null || v.length != 16
                        ? 'Debe tener 16 dígitos'
                        : null,
          ),
          buildTextField(
            label: 'Fecha de expiración',
            hint: 'Ej. 05/26',
            icon: Icons.date_range,
            controller: _expiryDateController,
            inputType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(5),
              ExpiryDateTextInputFormatter(), 
            ],
            validator: (v) {
              if (v == null || v.length != 5 || !v.contains('/')) {
                return 'Formato inválido (MM/AA)';
              }
              final parts = v.split('/');
              final mes = int.tryParse(parts[0]);
              if (mes == null || mes < 1 || mes > 12) return 'Mes inválido';
              return null;
            },
          ),

          buildTextField(
            label: 'CVV',
            hint: 'Ej. 123',
            icon: Icons.lock,
            controller: _cvvController,
            inputType: TextInputType.number,
            inputFormatters: [LengthLimitingTextInputFormatter(3)],
            validator:
                (v) =>
                    v == null || v.length != 3 ? 'Debe tener 3 dígitos' : null,
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
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                validator:
                    (v) =>
                        v == null || !RegExp(r'^\d{10}$').hasMatch(v)
                            ? 'Teléfono inválido'
                            : null,
              ),
              buildTextField(
                label: 'Dirección',
                hint: 'Calle, número, colonia',
                icon: Icons.home,
                controller: _addressController,
              ),
              buildTextField(
                label: 'Ciudad',
                hint: 'Ej. CDMX',
                icon: Icons.location_city,
                controller: _cityController,
              ),
              buildTextField(
                label: 'Código Postal',
                hint: 'Ej. 01234',
                icon: Icons.markunread_mailbox,
                controller: _postalCodeController,
                inputType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                validator:
                    (v) => v == null || v.length < 4 ? 'Código inválido' : null,
              ),
              SizedBox(height: 16),
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
                onChanged:
                    (value) => setState(() => _selectedPaymentMethod = value!),
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

class ExpiryDateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 4) {
      digits = digits.substring(0, 4);
    }

    String formatted = '';
    if (digits.length >= 3) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else {
      formatted = digits;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
