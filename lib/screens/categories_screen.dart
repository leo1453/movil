import 'package:flutter/material.dart';
import 'category_products_screen.dart';
import '../widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  void _openCategory(BuildContext context, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                CategoryProductsScreen(categoriaSeleccionada: categoryName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorías'),
        backgroundColor: Colors.deepPurple,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: [
          CategoryCard(
            title: 'Anime',
            image: 'assets/imagenes/anime.jpg',
            onTap: () => _openCategory(context, 'Anime'),
          ),
          CategoryCard(
            title: 'Videojuegos',
            image: 'assets/imagenes/juego.webp',
            onTap: () => _openCategory(context, 'Videojuegos'),
          ),
          CategoryCard(
            title: 'Cómics',
            image: 'assets/imagenes/comics.webp',
            onTap: () => _openCategory(context, 'Cómics'),
          ),
          CategoryCard(
            title: 'Películas',
            image: 'assets/imagenes/pelicula.webp',
            onTap: () => _openCategory(context, 'Películas'),
          ),
        ],
      ),
    );
  }
}
