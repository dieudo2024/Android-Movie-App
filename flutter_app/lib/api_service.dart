import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

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
  
    Future<void> addMovie(Movie movie) async {
      final url = Uri.parse('$baseUrl/movies');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': movie.title,
          'category': movie.category,
          'director': movie.director,
          'year': movie.year,
          'rating': movie.rating,
          'description': movie.description,
          'synopsis': movie.synopsis,
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add movie: \\n' + response.body);
      }
    }
}