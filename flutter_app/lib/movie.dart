class Movie {
  final int? id;
  final String title;
  final String category;
  final String director;
  final int year;
  final double rating;
  final String? description;
  final String synopsis;
  final DateTime createdAt;

  Movie({
    this.id,
    required this.title,
    required this.category,
    required this.director,
    required this.year,
    required this.rating,
    this.description,
    required this.synopsis,
    required this.createdAt,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      director: json['director'],
      year: json['year'],
      rating: (json['rating'] as num).toDouble(),
      description: json['description'],
      synopsis: json['synopsis'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}