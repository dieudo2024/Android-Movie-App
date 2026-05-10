import 'package:flutter/material.dart';
import 'api_service.dart';
import 'detail_screen.dart';
import 'favorites_service.dart';
import 'movie.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _api = ApiService();
  final FavoritesService _favorites = FavoritesService.instance;
  late Future<List<Movie>> _future;
  bool _shownError = false;

  @override
  void initState() {
    super.initState();
    _future = _loadFavoriteMovies();
  }

  Future<List<Movie>> _loadFavoriteMovies() async {
    await _favorites.load();
    final ids = _favorites.favoriteIds;
    if (ids.isEmpty) return <Movie>[];

    final List<Movie> results = <Movie>[];
    int page = 1;
    const int pageSize = 100;

    while (true) {
      final paged = await _api.fetchMovies(page: page, pageSize: pageSize);
      results.addAll(
        paged.items.where((m) => m.id != null && ids.contains(m.id)),
      );

      if (page >= paged.totalPages) break;
      page++;
    }

    results.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return results;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadFavoriteMovies();
      _shownError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading favorites.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // Show persisted favorites-loading errors from FavoritesService as a SnackBar once
          if (!_shownError && _favorites.errorMessage != null) {
            _shownError = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_favorites.errorMessage!)),
              );
            });
          }

          final movies = snapshot.data ?? <Movie>[];
          if (movies.isEmpty) {
            return const Center(child: Text('No favorites yet.'));
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    movie.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${movie.category} • ${movie.year}'),
                  trailing: IconButton(
                    tooltip: 'Remove from favorites',
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: movie.id == null
                        ? null
                        : () async {
                            await _favorites.toggle(movie.id!);
                            await _refresh();
                          },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(movie: movie),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
