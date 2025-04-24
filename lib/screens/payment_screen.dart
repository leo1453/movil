import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = 'Tarjeta de crédito';

  // Controladores para los campos de formulario
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  // Controladores para tarjeta de crédito / débito
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Controlador para PayPal
  final TextEditingController _paypalEmailController = TextEditingController();

  void _confirmPurchase() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Procesando pago...')));

      Future.delayed(Duration(seconds: 2), () {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text('¡Compra exitosa!'),
                content: Text(
                  'Gracias por tu compra de figuras coleccionables.',
                ),
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
              // Resumen de la orden
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
                      Row(
                        children: [
                          Image.asset(
                            'assets/imagenes/mona1.webp',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 10),
                          Expanded(child: Text('Figura Anime')),
                          Text('1500 MXN'),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset(
                            'assets/imagenes/videojuego.webp',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 10),
                          Expanded(child: Text('Figura Videojuego')),
                          Text('2200 MXN'),
                        ],
                      ),
                      Divider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: 3700 MXN',
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

              // Información de envío
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

              // Método de pago
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

              // Campos dinámicos según método de pago
              buildPaymentFields(),

              SizedBox(height: 24),

              // Botón confirmar compra
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
<<<<<<< HEAD
}
=======
}
>>>>>>> ed3662d3dd25d79a327c2264dc5b9d3303e35403
