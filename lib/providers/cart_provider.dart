import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItemModel> _items = [];
  bool _isInitialized = false;

  List<CartItemModel> get items => _items;
  bool get isInitialized => _isInitialized;

  CartProvider() {
    _loadCart();
  }

  // Persistent Cache Logic
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cached_cart');
      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        _items = decoded.map((item) {
          // This assumes MenuItemModel has a fromMap/toJson
          // We'll need to ensure MenuItemModel is robust
          return CartItemModel(
            menuItem: MenuItemModel.fromMap(item['menuItem']),
            quantity: item['quantity'],
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('CartProvider: Error loading cart: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items.map((item) => {
        'menuItem': item.menuItem.toMap(),
        'quantity': item.quantity,
      }).toList());
      await prefs.setString('cached_cart', cartJson);
    } catch (e) {
      debugPrint('CartProvider: Error saving cart: $e');
    }
  }

  void addToCart(MenuItemModel item) {
    final index = _items.indexWhere((cartItem) => cartItem.menuItem.id == item.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItemModel(menuItem: item));
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String itemId) {
    _items.removeWhere((item) => item.menuItem.id == itemId);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    final index = _items.indexWhere((item) => item.menuItem.id == itemId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get deliveryFee => _items.isEmpty ? 0 : 25.0; // Flat fee for demo
  double get tax => subtotal * 0.05; // 5% GST
  double get total => subtotal + deliveryFee + tax;
}
