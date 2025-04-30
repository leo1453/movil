import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  ProductDetailScreen({required this.productData});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double _ratingPromedio = 0;
  int _cartItemCount = 0;
  int _quantity = 1;
  int _currentImageIndex = 0;
  final TextEditingController _comentarioController = TextEditingController();
  int _rating = 5;
  List<Map<String, dynamic>> _comentariosLocal = [];

  @override
  Widget build(BuildContext context) {
    final product = widget.productData;
    final List<String> imagenes = _obtenerListaImagenes(
      product['imagenes'] ?? product['imagen'],
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          product['nombre'] ?? 'Producto',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagenes(imagenes),
            SizedBox(height: 24),
            Text(
              product['nombre'] ?? 'Producto',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('productos')
      .doc(widget.productData['id'])
      .collection('comentarios')
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Row(
        children: List.generate(5, (_) => Icon(Icons.star_border, size: 20, color: Colors.amber)),
      );
    }

    final docs = snapshot.data!.docs;
    double suma = 0;
    int total = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('rating')) {
        suma += (data['rating'] ?? 0).toDouble();
        total++;
      }
    }

    final promedio = total > 0 ? suma / total : 0;

    return Row(
      children: List.generate(5, (index) {
        if (promedio >= index + 1) {
          return Icon(Icons.star, size: 20, color: Colors.amber);
        } else if (promedio >= index + 0.5) {
          return Icon(Icons.star_half, size: 20, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, size: 20, color: Colors.amber);
        }
      }),
    );
  },
),



            SizedBox(height: 8),
            Text(
              '${product['precio']} MXN',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 16),
            Text(
              product['descripcion'] ?? 'Sin descripción disponible.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            SizedBox(height: 30),
            _buildSectionTitle('Características'),
            _buildDetailRow('Marca', product['marca']),
            _buildDetailRow('Modelo', product['modelo']),
            _buildDetailRow('Material', product['material']),
            _buildDetailRow('Color', product['color']),
            _buildDetailRow('Dimensiones', product['dimensiones']),
            _buildDetailRow('Peso', product['peso']),
            SizedBox(height: 30),
            _buildSectionTitle('Compra'),
            _buildCantidadSelector(),
            SizedBox(height: 20),
            _buildAgregarAlCarrito(),
            SizedBox(height: 30),
            Divider(thickness: 1.5),
            _buildSectionTitle('Opiniones de clientes'),
            _buildAgregarComentarioSection(),
            SizedBox(height: 10),
            _buildComentariosSection(),
            Divider(thickness: 1.5),
            _buildSectionTitle('Productos similares'),
            _buildProductosSimilares(
              product['categoria'],
              widget.productData['id'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagenes(List<String> imagenes) {
    if (imagenes.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ImagenesFullscreen(
                  imagenes: imagenes,
                  initialIndex: _currentImageIndex,
                ),
          ),
        );
      },
      child: SizedBox(
        height: 300,
        child: PageView.builder(
          itemCount: imagenes.length,
          onPageChanged: (index) => setState(() => _currentImageIndex = index),
          itemBuilder:
              (context, index) => Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.white,
                    constraints: BoxConstraints(maxWidth: 250),
                    child: Image.network(
                      imagenes[index],
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  String formatTimeAgo(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}'; // formato normal si es muy viejo
    } else if (difference.inDays >= 1) {
      return 'hace ${difference.inDays} día(s)';
    } else if (difference.inHours >= 1) {
      return 'hace ${difference.inHours} hora(s)';
    } else if (difference.inMinutes >= 1) {
      return 'hace ${difference.inMinutes} minuto(s)';
    } else {
      return 'recién ahora';
    }
  }

  Widget _buildComentariosSection() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('productos')
              .doc(widget.productData['id'])
              .collection('comentarios')
              .orderBy('fecha', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        List<Map<String, dynamic>> comentarios = [];

        if (snapshot.hasData) {
          comentarios =
              snapshot.data!.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
        }

        // Combinar los comentarios locales primero
        final todosComentarios = [..._comentariosLocal, ...comentarios];

        if (todosComentarios.isEmpty) return Text('No hay opiniones todavía.');

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: todosComentarios.length,
          itemBuilder: (context, index) {
            final data = todosComentarios[index];

            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(vertical: 6),
              child: Card(
                elevation: 3,
                child: ListTile(
                  leading: _buildStars(data['rating'] ?? 5),
                  title: Text(
                    data['usuario'] ?? 'Anónimo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['texto'] ?? '',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAgregarComentarioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tu calificación:'),
        Row(
          children: List.generate(
            5,
            (index) => IconButton(
              icon: Icon(
                _rating > index ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _rating = index + 1;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _comentarioController,
          decoration: InputDecoration(
            hintText: 'Escribe tu opinión...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: Icon(Icons.send, color: Colors.deepPurple),
              onPressed: _enviarComentario,
            ),
          ),
        ),
      ],
    );
  }

  void _enviarComentario() async {
    final user = FirebaseAuth.instance.currentUser;
    final texto = _comentarioController.text.trim();

    if (user != null && texto.isNotEmpty) {
      final nuevoComentario = {
        'texto': texto,
        'rating': _rating,
        'usuario': user.email ?? 'Anónimo',
        'fecha': Timestamp.fromDate(DateTime.now()),
      };

      await FirebaseFirestore.instance
          .collection('productos')
          .doc(widget.productData['id'])
          .collection('comentarios')
          .add(nuevoComentario);

      _comentarioController.clear();
      _rating = 5;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comentario enviado correctamente')),
      );
    }
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 18,
          color: Colors.amber,
        ),
      ),
    );
  }

  Widget _buildCantidadSelector() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: CircleBorder(),
            padding: EdgeInsets.all(12),
          ),
          child: Icon(Icons.remove, size: 20, color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$_quantity', style: TextStyle(fontSize: 18)),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _quantity++),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: CircleBorder(),
            padding: EdgeInsets.all(12),
          ),
          child: Icon(Icons.add, size: 20, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAgregarAlCarrito() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
        label: Text(
          'Agregar al carrito',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: _addToCart,
      ),
    );
  }

  void _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('carrito')
          .add({
            'nombre': widget.productData['nombre'],
            'precio': widget.productData['precio'],
            'imagen': _obtenerImagenPrincipal(widget.productData),
            'cantidad': _quantity,
            'fechaAgregado': FieldValue.serverTimestamp(),
          });

      setState(() {
        _cartItemCount += _quantity;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_quantity producto(s) agregado(s) al carrito'),
        ),
      );
    }
  }

  List<String> _obtenerListaImagenes(dynamic imagenes) {
    if (imagenes is List) return imagenes.whereType<String>().toList();
    if (imagenes is String && imagenes.trim().isNotEmpty) return [imagenes];
    return [];
  }

  String _obtenerImagenPrincipal(Map<String, dynamic> data) {
    if (data['imagenes'] != null &&
        data['imagenes'] is List &&
        data['imagenes'].isNotEmpty)
      return data['imagenes'][0];
    if (data['imagen'] != null && data['imagen'].toString().isNotEmpty)
      return data['imagen'];
    return '';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || (value is String && value.isEmpty))
      return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text('$label: $value', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildProductosSimilares(String categoria, String productoId) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('productos')
              .where('categoria', isEqualTo: categoria)
              .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        final productos =
            snapshot.data!.docs.where((doc) => doc.id != productoId).toList();

        if (productos.isEmpty) return SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'También podría interesarte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final data = productos[index].data() as Map<String, dynamic>;
                  final imagenPrincipal = _obtenerImagenPrincipal(data);

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProductDetailScreen(
                                productData: {
                                  ...data,
                                  'id': productos[index].id,
                                },
                              ),
                        ),
                      );
                    },
                    child: Container(
                      width: 160,
                      margin: EdgeInsets.only(right: 12),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child:
                                    imagenPrincipal.isNotEmpty
                                        ? Image.network(
                                          imagenPrincipal,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) =>
                                                  Icon(Icons.broken_image),
                                        )
                                        : Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['nombre'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${data['precio']} MXN',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<double> _obtenerPromedioRating() async {
    final comentariosSnapshot =
        await FirebaseFirestore.instance
            .collection('productos')
            .doc(widget.productData['id'])
            .collection('comentarios')
            .get();

    if (comentariosSnapshot.docs.isEmpty) return 0;

    double sumaRatings = 0;
    int totalRatings = 0;

    for (var doc in comentariosSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('rating')) {
        sumaRatings += (data['rating'] ?? 0).toDouble();
        totalRatings++;
      }
    }

    if (totalRatings == 0) return 0;
    return sumaRatings / totalRatings;
  }
}

class ImagenesFullscreen extends StatefulWidget {
  final List<String> imagenes;
  final int initialIndex;

  ImagenesFullscreen({required this.imagenes, this.initialIndex = 0});

  @override
  _ImagenesFullscreenState createState() => _ImagenesFullscreenState();
}

class _ImagenesFullscreenState extends State<ImagenesFullscreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagenes.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.imagenes[index],
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 100,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
