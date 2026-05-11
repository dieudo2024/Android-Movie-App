import 'package:flutter/material.dart';
import 'movie.dart';
import 'api_service.dart';
import 'add_movie_screen.dart';
import 'favorites_service.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService apiService = ApiService();
  final FavoritesService _favorites = FavoritesService.instance;
  late Movie currentMovie;

  @override
  void initState() {
    super.initState();
    currentMovie = widget.movie;
    _favorites.addListener(_update);
  }

  @override
  void dispose() {
    _favorites.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  // CONFIRMATION DIALOG: Required for functional test cases
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Movie?"),
        content: Text("Are you sure you want to delete ${currentMovie.title}?"),
        actions: [
          TextButton(child: const Text("CANCEL"), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              bool success = await apiService.deleteMovie(currentMovie.id!);
              if (success) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to Browse and trigger refresh
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFav = currentMovie.id != null ? _favorites.isFavorite(currentMovie.id!) : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentMovie.title),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
            onPressed: () async {
              if (currentMovie.id != null) await _favorites.toggle(currentMovie.id!);
            },
          ),
          // EDIT BUTTON
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMovieScreen(movieToEdit: currentMovie)),
              );
              // If edited successfully, return to list to refresh data
              if (result == true) Navigator.pop(context, true);
            },
          ),
          // DELETE BUTTON
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentMovie.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Chip(label: Text(currentMovie.category)),
            const Divider(height: 30),
            _infoRow("Director", currentMovie.director),
            _infoRow("Year", currentMovie.year.toString()),
            _infoRow("Rating", '⭐ ${currentMovie.rating}/10'),
            _infoRow("Description", currentMovie.description ?? 'N/A'),
            const SizedBox(height: 20),
            const Text("Synopsis:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(currentMovie.synopsis, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}