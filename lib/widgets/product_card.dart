import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String image;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  ProductCard({
    required this.title,
    required this.price,
    required this.image,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen
                Flexible(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Container(
                      color: Colors.grey[100],
                      width: double.infinity,
                      child: Image.network(
                        image,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ),

                // Separación mínima
                SizedBox(height: 6),

                // Información del producto
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
