import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCard extends StatefulWidget {
  final String title;
  final String price;
  final String image;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onAddToCart;
  final String productId;
  final int stock;

  ProductCard({
    required this.title,
    required this.price,
    required this.image,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.productId,
    required this.stock,
    this.onAddToCart,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.96);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final bool hasValidImage = widget.image.trim().startsWith('http');

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 150),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 9,
                    spreadRadius: 2,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        color: Colors.white,
                        child: hasValidImage
                            ? Image.network(
                                widget.image,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                ),
                              )
                            : Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('productos')
                                .doc(widget.productId)
                                .collection('comentarios')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Row(
                                  children: [
                                    ...List.generate(5, (_) => Icon(Icons.star_border, size: 14, color: Colors.amber)),
                                    SizedBox(width: 4),
                                    Text('0.0/5', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
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
                                children: [
                                  ...List.generate(5, (index) {
                                    if (promedio >= index + 1) {
                                      return Icon(Icons.star, size: 14, color: Colors.amber);
                                    } else if (promedio >= index + 0.5) {
                                      return Icon(Icons.star_half, size: 14, color: Colors.amber);
                                    } else {
                                      return Icon(Icons.star_border, size: 14, color: Colors.amber);
                                    }
                                  }),
                                  SizedBox(width: 4),
                                  Text('${promedio.toStringAsFixed(1)}/5', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              );
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.price,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_shopping_cart),
                                color: widget.stock > 0 ? Colors.deepPurple : Colors.grey,
                                iconSize: 20,
                                onPressed: widget.stock > 0 ? widget.onAddToCart : null,
                                tooltip: widget.stock > 0 ? 'Agregar al carrito' : 'Sin stock',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Etiqueta "Sin stock"
            if (widget.stock == 0)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Sin stock',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            // Icono de favorito
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: widget.onFavoriteToggle,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.isFavorite ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
