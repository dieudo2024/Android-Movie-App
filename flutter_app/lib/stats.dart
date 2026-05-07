class Stats {
  final int totalMovies;
  final double avgRating;
  final double minRating;
  final double maxRating;
  final double avgYear;
  final int? oldestYear;
  final int? newestYear;
  final Map<String, int> moviesByCategory;
  final Map<String, double> avgRatingByCategory;

  const Stats({
    required this.totalMovies,
    required this.avgRating,
    required this.minRating,
    required this.maxRating,
    required this.avgYear,
    required this.oldestYear,
    required this.newestYear,
    required this.moviesByCategory,
    required this.avgRatingByCategory,
  });

  static Map<String, int> _parseIntMap(dynamic value) {
    if (value is! Map) return <String, int>{};
    return value.map((key, v) {
      final parsed = v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0;
      return MapEntry(key.toString(), parsed);
    });
  }

  static Map<String, double> _parseDoubleMap(dynamic value) {
    if (value is! Map) return <String, double>{};
    return value.map((key, v) {
      final parsed = v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
      return MapEntry(key.toString(), parsed);
    });
  }

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalMovies: (json['total_movies'] as num?)?.toInt() ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      minRating: (json['min_rating'] as num?)?.toDouble() ?? 0.0,
      maxRating: (json['max_rating'] as num?)?.toDouble() ?? 0.0,
      avgYear: (json['avg_year'] as num?)?.toDouble() ?? 0.0,
      oldestYear: (json['oldest_year'] as num?)?.toInt(),
      newestYear: (json['newest_year'] as num?)?.toInt(),
      moviesByCategory: _parseIntMap(json['movies_by_category']),
      avgRatingByCategory: _parseDoubleMap(json['avg_rating_by_category']),
    );
  }
}
