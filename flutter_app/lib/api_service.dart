import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie.dart';

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
      pageSize: json['page_size'] ?? itemsJson.length,
      total: json['total'] ?? itemsJson.length,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<PagedMovies> fetchMovies({
    String? search,
    String? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParameters = <String, String>{};
    if (search != null && search.isNotEmpty) queryParameters['title'] = search;
    if (category != null && category.isNotEmpty) queryParameters['category'] = category;
    queryParameters['page'] = page.toString();
    queryParameters['page_size'] = pageSize.toString();

    final uri = Uri.parse('$baseUrl/movies').replace(queryParameters: queryParameters);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return PagedMovies.fromJson(data);
    } else {
      throw Exception('Failed to fetch movies: ${response.statusCode}');
    }
  }
  
  Future<bool> addMovie(Movie movie) async {
    final url = Uri.parse('$baseUrl/movies');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(movie.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}