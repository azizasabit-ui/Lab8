import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  final String size;
  int qty;
  CartItem(this.product, this.size, this.qty);
  double get subtotal => product.price * qty;
}

class SavedLook {
  final String name;
  final Map<ProductCategory, Product> items;
  final int score;
  const SavedLook(this.name, this.items, this.score);
}

/// App-wide state (favorites, cart, saved looks).
/// Will be replaced by BLoC in later milestones.
class AppState extends ChangeNotifier {
  final Set<String> _favorites = {};
  final List<CartItem> _cart = [];
  final List<SavedLook> _looks = [];

  List<CartItem> get cart => List.unmodifiable(_cart);
  List<SavedLook> get looks => List.unmodifiable(_looks);
  int get cartCount => _cart.fold(0, (s, c) => s + c.qty);
  double get total => _cart.fold(0.0, (s, c) => s + c.subtotal);

  bool isFavorite(String id) => _favorites.contains(id);
  int get favoritesCount => _favorites.length;

  void toggleFavorite(String id) {
    if (!_favorites.add(id)) _favorites.remove(id);
    notifyListeners();
  }

  void addToCart(Product p, String size, {int qty = 1}) {
    final i =
        _cart.indexWhere((c) => c.product.id == p.id && c.size == size);
    if (i >= 0) {
      _cart[i].qty += qty;
    } else {
      _cart.add(CartItem(p, size, qty));
    }
    notifyListeners();
  }

  void changeQty(CartItem item, int delta) {
    item.qty += delta;
    if (item.qty <= 0) _cart.remove(item);
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cart.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void saveLook(SavedLook look) {
    _looks.add(look);
    notifyListeners();
  }

  void deleteLook(SavedLook look) {
    _looks.remove(look);
    notifyListeners();
  }
}

final AppState appState = AppState();
