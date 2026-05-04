import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<Movie>> fetchMovies({String? search, String? category}) async {
    // 1. Better URL building to avoid trailing '&' or '?' issues
    final queryParameters = <String, String>{};
    if (search != null && search.isNotEmpty) queryParameters['title'] = search;
    if (category != null && category.isNotEmpty) queryParameters['category'] = category;

    final uri = Uri.parse('$baseUrl/movies').replace(queryParameters: queryParameters);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // Ensure 'items' exists and isn't null before mapping
      final List<dynamic> items = data['items'] ?? [];
      return items.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch movies: ${response.statusCode}');
    }
  }

  Future<bool> addMovie(Movie movie) async {
    final response = await http.post(
      Uri.parse('$baseUrl/movies'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(movie.toJson()),
    );

    // 2. FastAPI usually returns 201 (Created) for successful POST requests
    return response.statusCode == 200 || response.statusCode == 201; 
  }
}
