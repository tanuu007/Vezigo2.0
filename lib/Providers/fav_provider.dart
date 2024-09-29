import 'package:flutter/material.dart';
import 'package:vezigo/Api_Models/list_products.dart';

class FavoriteProvider with ChangeNotifier {
  final List<Product> _favoriteItems = [];

  List<Product> get favoriteItems => _favoriteItems;

  bool isFavorite(Product item) {
    return _favoriteItems.contains(item);
  }

  void toggleFavorite(Product item) {
    if (isFavorite(item)) {
      _favoriteItems.remove(item);
    } else {
      _favoriteItems.add(item);
    }
    notifyListeners();
  }

  void updateItem(Product item) {
    int index = _favoriteItems.indexWhere((i) => i.id == item.id); 
    if (index != -1) {
      _favoriteItems[index] = item;
      notifyListeners();
    }
  }
}
