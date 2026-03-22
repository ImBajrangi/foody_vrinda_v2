import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItemModel> _items = [];
  String? _shopId;
  bool _isInitialized = false;

  List<CartItemModel> get items => _items;
  String? get shopId => _shopId;
  bool get isEmpty => _items.isEmpty;
  bool get isInitialized => _isInitialized;

  CartProvider() {
    _loadCart();
  }

  void setShopId(String? id) {
    if (_shopId != id) {
      _items.clear();
      _shopId = id;
      _saveCart();
      notifyListeners();
    }
  }

  // Persistent Cache Logic
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cached_cart');
      _shopId = prefs.getString('cached_shop_id');
      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        final loadedItems = decoded.map((item) {
          return CartItemModel(
            menuItem: MenuItemModel.fromMap(item['menuItem']),
            quantity: item['quantity'],
          );
        }).toList();

        // Merge loaded items with any items added before initialization
        for (var loadedItem in loadedItems) {
          final index = _items.indexWhere((i) => i.menuItem.id == loadedItem.menuItem.id);
          if (index != -1) {
            _items[index].quantity += loadedItem.quantity;
          } else {
            _items.add(loadedItem);
          }
        }
      }
    } catch (e) {
      debugPrint('CartProvider: Error loading cart: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    if (!_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items.map((item) => {
        'menuItem': item.menuItem.toMap(),
        'quantity': item.quantity,
      }).toList());
      await prefs.setString('cached_cart', cartJson);
      if (_shopId != null) {
        await prefs.setString('cached_shop_id', _shopId!);
      } else {
        await prefs.remove('cached_shop_id');
      }
    } catch (e) {
      debugPrint('CartProvider: Error saving cart: $e');
    }
  }

  void addToCart(MenuItemModel item, {int quantity = 1}) {
    final index = _items.indexWhere((cartItem) => cartItem.menuItem.id == item.id);
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItemModel(menuItem: item, quantity: quantity));
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
