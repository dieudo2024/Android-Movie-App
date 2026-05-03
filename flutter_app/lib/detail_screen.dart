import 'package:flutter/material.dart';
import 'movie.dart';

class DetailScreen extends StatelessWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Toggle logic comes in Deliverable 3
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