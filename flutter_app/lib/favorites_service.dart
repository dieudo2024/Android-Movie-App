import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  static const String _prefsKey = 'favorite_movie_ids';
  static final FavoritesService instance = FavoritesService._();

  FavoritesService._();

  bool _loaded = false;
  Set<int> _favoriteIds = <int>{};
  String? _errorMessage;

  /// Last error message from async operations, if any.
  String? get errorMessage => _errorMessage;

  Set<int> get favoriteIds => _favoriteIds;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey) ?? <String>[];

      _favoriteIds = raw
          .map((s) => int.tryParse(s))
          .whereType<int>()
          .toSet();

      _loaded = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load favorites: $e';
      _loaded = false;
      notifyListeners();
    }
  }

  bool isFavorite(int movieId) {
    return _favoriteIds.contains(movieId);
  }

  Future<void> toggle(int movieId) async {
    if (!_loaded) {
      await load();
    }
    // Apply optimistic change, persist, and revert on failure.
    final bool wasFavorite = _favoriteIds.contains(movieId);

    if (wasFavorite) {
      _favoriteIds.remove(movieId);
    } else {
      _favoriteIds.add(movieId);
    }

    try {
      await _persist();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      // Revert optimistic update
      if (wasFavorite) {
        _favoriteIds.add(movieId);
      } else {
        _favoriteIds.remove(movieId);
      }
      _errorMessage = 'Failed to update favorites: $e';
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _favoriteIds.map((id) => id.toString()).toList()
        ..sort((a, b) {
          final ai = int.tryParse(a) ?? 0;
          final bi = int.tryParse(b) ?? 0;
          return ai.compareTo(bi);
        });

      final ok = await prefs.setStringList(_prefsKey, list);
      if (!ok) {
        throw Exception('SharedPreferences refused to save data');
      }
    } catch (e) {
      throw Exception('Failed to persist favorites: $e');
    }
  }
}
