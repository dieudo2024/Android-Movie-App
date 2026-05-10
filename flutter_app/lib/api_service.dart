import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie.dart';
import 'stats.dart';

class PagedMovies {
  final List<Movie> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  const PagedMovies({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory PagedMovies.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>?) ?? [];
    return PagedMovies(
      items: itemsJson
          .map((item) => Movie.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10, // Default to 10 if missing
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

class ApiService {
  // 10.0.2.2 is the correct alias for localhost on the Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<Stats> fetchStats() async {
    final uri = Uri.parse('$baseUrl/stats');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Stats.fromJson(data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<PagedMovies> fetchMovies({
    String? search,
    String? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    // Build query parameters safely
    final queryParameters = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParameters['title'] = search;
    }
    if (category != null && category.isNotEmpty) {
      queryParameters['category'] = category;
    }

    final uri = Uri.parse('$baseUrl/movies').replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PagedMovies.fromJson(data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }
  
  Future<bool> addMovie(Movie movie) async {
    final url = Uri.parse('$baseUrl/movies');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(movie.toJson()),
      );
      // Returns true if created (201) or success (200)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      // Extract server message when available
      String message;
      try {
        final body = json.decode(response.body);
        message = body['detail'] ?? body['message'] ?? response.body;
      } catch (_) {
        message = response.body;
      }

      throw Exception('Server error ${response.statusCode}: $message');
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  // Update Movie (PUT)
  Future<bool> updateMovie(int id, Movie movie) async {
    final response = await http.put(
      Uri.parse('$baseUrl/movies/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(movie.toJson()),
    );
    return response.statusCode == 200;
  }

  // Delete Movie (DELETE)
  Future<bool> deleteMovie(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/movies/$id'));
    return response.statusCode == 200;
  }
}
