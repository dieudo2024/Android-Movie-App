import 'dart:convert';
import 'package:http/http.dart' as http;
import '../movie.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  Future<List<Movie>> fetchMovies({String? search, String? category}) async {
    // Building the query to get movies
    String url = '$baseUrl/movies?';
    if (search != null) url += 'title=$search&';
    if (category != null) url += 'category=$category';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> items = data['items'];
      return items.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch movies');
    }
  }
}