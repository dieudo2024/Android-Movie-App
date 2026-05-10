import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  static const String _prefsKey = 'favorite_movie_ids';
  static final FavoritesService instance = FavoritesService._();

  FavoritesService._();

  bool _loaded = false;
  Set<int> _favoriteIds = <int>{};

  Set<int> get favoriteIds => _favoriteIds;

  Future<void> load() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? <String>[];

    _favoriteIds = raw
        .map((s) => int.tryParse(s))
        .whereType<int>()
        .toSet();

    _loaded = true;
    notifyListeners();
  }

  bool isFavorite(int movieId) {
    return _favoriteIds.contains(movieId);
  }

  Future<void> toggle(int movieId) async {
    if (!_loaded) {
      await load();
    }

    if (_favoriteIds.contains(movieId)) {
      _favoriteIds.remove(movieId);
    } else {
      _favoriteIds.add(movieId);
    }

    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _favoriteIds.map((id) => id.toString()).toList()
      ..sort((a, b) {
        final ai = int.tryParse(a) ?? 0;
        final bi = int.tryParse(b) ?? 0;
        return ai.compareTo(bi);
      });

    await prefs.setStringList(_prefsKey, list);
  }
}
