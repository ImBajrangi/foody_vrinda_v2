import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item_model.dart';

class FavoritesProvider with ChangeNotifier {
  List<MenuItemModel> _favorites = [];
  bool _isInitialized = false;

  List<MenuItemModel> get favorites => _favorites;
  bool get isInitialized => _isInitialized;

  FavoritesProvider() {
    _loadFavorites();
  }

  bool isFavorite(String id) {
    return _favorites.any((item) => item.id == id);
  }

  Future<void> toggleFavorite(MenuItemModel item) async {
    final index = _favorites.indexWhere((fav) => fav.id == item.id);
    if (index != -1) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(item);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favJson = prefs.getString('cached_favorites');
      if (favJson != null) {
        final List<dynamic> decoded = jsonDecode(favJson);
        _favorites = decoded.map((item) => MenuItemModel.fromMap(item)).toList();
      }
    } catch (e) {
      debugPrint('FavoritesProvider: Error loading: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    if (!_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final favJson = jsonEncode(_favorites.map((item) => item.toMap()).toList());
      await prefs.setString('cached_favorites', favJson);
    } catch (e) {
      debugPrint('FavoritesProvider: Error saving: $e');
    }
  }
}
