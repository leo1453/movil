import 'package:flutter/material.dart';
import '../widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categorías'), backgroundColor: Colors.deepPurple),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: [
          CategoryCard(title: 'Anime', image: 'assets/imagenes/anime.jpg'),
          CategoryCard(title: 'Videojuegos', image: 'assets/imagenes/juego.webp'),
          CategoryCard(title: 'Cómics', image: 'assets/imagenes/comics.webp'),
          CategoryCard(title: 'Películas', image: 'assets/imagenes/pelicula.webp'),
        ],
      ),
    );
  }
}