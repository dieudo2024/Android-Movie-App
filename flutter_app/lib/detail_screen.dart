import 'package:flutter/material.dart';
import 'movie.dart';
import 'favorites_service.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FavoritesService _favorites = FavoritesService.instance;
  late final VoidCallback _favoritesListener;

  @override
  void initState() {
    super.initState();
    _favoritesListener = () {
      if (!mounted) return;
      setState(() {});
    };
    _favorites.addListener(_favoritesListener);
    _favorites.load();
  }

  @override
  void dispose() {
    _favorites.removeListener(_favoritesListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final canFavorite = movie.id != null;
    final isFav = canFavorite ? _favorites.isFavorite(movie.id!) : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: canFavorite ? Colors.red : null,
            ),
            tooltip: canFavorite ? 'Toggle favorite' : 'No movie id to favorite',
            onPressed: !canFavorite
                ? null
                : () async {
                    await _favorites.toggle(movie.id!);
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(movie.category)),
                const SizedBox(width: 10),
                Text("${movie.year} • ⭐ ${movie.rating}"),
              ],
            ),
            const Divider(height: 30),
            _buildInfoSection("Director", movie.director),
            const SizedBox(height: 16),
            _buildInfoSection("Synopsis", movie.synopsis),
            const SizedBox(height: 16),
            if (movie.description != null)
              _buildInfoSection("Additional Description", movie.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}