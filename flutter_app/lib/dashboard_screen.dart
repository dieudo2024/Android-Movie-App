import 'package:flutter/material.dart';
import 'api_service.dart';
import 'browse_screen.dart';
import 'movie.dart';
import 'detail_screen.dart';
import 'stats.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final ApiService _api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<Stats>(
        future: _api.fetchStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading stats. Make sure your FastAPI server is running.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final stats = snapshot.data;
          if (stats == null) {
            return const Center(child: Text('No stats available.'));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _sectionTitle('Overview'),
              _infoTile('Total movies', stats.totalMovies.toString()),
              const SizedBox(height: 12),

              _sectionTitle('Top 3 highest-rated movies'),
              ..._topMoviesTiles(context, stats.topMovies),
              const SizedBox(height: 12),

              _sectionTitle('Ratings'),
              _infoTile('Average rating', stats.avgRating.toStringAsFixed(2)),
              _infoTile('Min rating', stats.minRating.toStringAsFixed(2)),
              _infoTile('Max rating', stats.maxRating.toStringAsFixed(2)),
              const SizedBox(height: 12),

              _sectionTitle('Years'),
              _infoTile('Average year', stats.avgYear.toStringAsFixed(2)),
              _infoTile('Oldest year', stats.oldestYear?.toString() ?? 'N/A'),
              _infoTile('Newest year', stats.newestYear?.toString() ?? 'N/A'),
              const SizedBox(height: 12),

              _sectionTitle('Movies by category'),
              ..._mapToTilesInt(context, stats.moviesByCategory),
              const SizedBox(height: 12),

              _sectionTitle('Average rating by category'),
              ..._mapToTilesDouble(context, stats.avgRatingByCategory),
              const SizedBox(height: 12),

            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _openCategory(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowseScreen(initialCategory: category),
      ),
    );
  }

  Widget _infoTile(String label, String value, {VoidCallback? onTap}) {
    return Card(
      elevation: 1,
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }

  List<Widget> _mapToTilesInt(BuildContext context, Map<String, int> map) {
    if (map.isEmpty) {
      return [const Text('No category data.')];
    }

    final entries = map.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return entries
        .map(
          (e) => _infoTile(
            e.key,
            e.value.toString(),
            onTap: () => _openCategory(context, e.key),
          ),
        )
        .toList(growable: false);
  }

  List<Widget> _mapToTilesDouble(BuildContext context, Map<String, double> map) {
    if (map.isEmpty) {
      return [const Text('No category rating data.')];
    }

    final entries = map.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return entries
        .map(
          (e) => _infoTile(
            e.key,
            e.value.toStringAsFixed(2),
            onTap: () => _openCategory(context, e.key),
          ),
        )
        .toList(growable: false);
  }

  List<Widget> _topMoviesTiles(BuildContext context, List<Movie> movies) {
    if (movies.isEmpty) {
      return [const Text('No top movies available.')];
    }

    return List<Widget>.generate(movies.length, (index) {
      final movie = movies[index];
      return Card(
        elevation: 1,
        child: ListTile(
          leading: CircleAvatar(
            child: Text('${index + 1}'),
          ),
          title: Text(movie.title),
          subtitle: Text('${movie.category} • ${movie.year}'),
          trailing: Text(
            '⭐ ${movie.rating.toStringAsFixed(1)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
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
    });
  }
}