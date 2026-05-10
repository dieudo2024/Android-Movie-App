import 'package:flutter/material.dart';
import 'movie.dart';
import 'api_service.dart';
import 'add_movie_screen.dart';
import 'favorites_service.dart'; // Import your existing service

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService apiService = ApiService();
  final FavoritesService _favorites = FavoritesService.instance; // Use your existing instance
  late Movie currentMovie;

  @override
  void initState() {
    super.initState();
    currentMovie = widget.movie;
    
    // Listen for changes so the heart updates if toggled elsewhere
    _favorites.addListener(_update);
  }

  @override
  void dispose() {
    _favorites.removeListener(_update);
    super.dispose();
  }

  // void _update() => setState(() {});

  // void _confirmDelete() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("Delete Movie?"),
  //       content: Text("Are you sure you want to delete ${currentMovie.title}?"),
  //       actions: [
  //         TextButton(child: const Text("CANCEL"), onPressed: () => Navigator.pop(context)),
  //         TextButton(
  //           child: const Text("DELETE", style: TextStyle(color: Colors.red)),
  //           onPressed: () async {
  //             bool success = await apiService.deleteMovie(currentMovie.id!);
  //             if (success) {
  //               Navigator.pop(context);
  //               Navigator.pop(context, true); 
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // Check if favorited using your existing service logic
    final isFav = currentMovie.id != null ? _favorites.isFavorite(currentMovie.id!) : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentMovie.title),
        actions: [
          // Favorite Toggle (Matches your Browse Screen logic)
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
            onPressed: () async {
              if (currentMovie.id != null) {
                await _favorites.toggle(currentMovie.id!);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMovieScreen(movieToEdit: currentMovie)),
              );
              if (result == true) Navigator.pop(context, true);
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _confirmDelete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentMovie.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Chip(label: Text(currentMovie.category)),
            const Divider(height: 30),
            Text("Director: ${currentMovie.director}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Rating: ⭐ ${currentMovie.rating}/10", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text("Synopsis:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(currentMovie.synopsis, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}