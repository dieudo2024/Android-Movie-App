import 'package:flutter/material.dart';
import 'browse_screen.dart';
import 'add_movie_screen.dart';
import 'dashboard_screen.dart';
void main() {
  runApp(const MovieCatalogApp());
}

class MovieCatalogApp extends StatelessWidget {
  const MovieCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: BrowseScreen(),
      routes: {
        '/add': (context) => AddMovieScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}