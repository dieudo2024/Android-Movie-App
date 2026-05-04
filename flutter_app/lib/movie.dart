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

  // Convert JSON (from Backend) to Movie Object
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      director: json['director'] ?? '',
      year: json['year'] ?? 0,
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      description: json['description'],
      synopsis: json['synopsis'] ?? '',
      // Backend usually uses 'created_at', Flutter variable is 'createdAt'
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  // Convert Movie Object to JSON (to send to Backend)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'category': category,
      'director': director,
      'year': year,
      'rating': rating,
      'description': description,
      'synopsis': synopsis,
      // Convert DateTime back to String for the database
      'created_at': createdAt.toIso8601String(),
    };
  }
}
