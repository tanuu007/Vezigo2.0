// import 'package:flutter/foundation.dart';
// import 'package:vezigo/models/cart_item.dart';

// class Cart with ChangeNotifier {
//   final List<CartItem> _items = [];

//   List<CartItem> get items => _items;

//   void addItem(CartItem item) {
   
//     final index = _items.indexWhere((i) => i.name == item.name && i.package == item.package);
    
//     if (index != -1) {
    
//       _items[index] = CartItem(
//         name: _items[index].name,
//         price: _items[index].price,
//         quantity: _items[index].quantity + item.quantity,
//         image: _items[index].image,
//         package: _items[index].package
//       );
//     } else {
     
//       _items.add(item);
//     }
//     notifyListeners();
//   }

//   void updateItemQuantity(String name, int quantity, String packageId) {
//     final index = _items.indexWhere((i) => i.name == name && i.package.id == packageId);
//     if (index != -1) {
//       if (quantity <= 0) {
//         _items.removeAt(index);
//       } else {
//         _items[index] = CartItem(
//           name: _items[index].name,
//           price: _items[index].price,
//           quantity: quantity,
//           image: _items[index].image,
//           package: _items[index].package,
//         );
//       }
//       notifyListeners();
//     }
//   }

//   void removeItem(String name, String packageId) {
//     _items.removeWhere((i) => i.name == name && i.package.id == packageId);
//     notifyListeners();
//   }

//   void clearCart() {
//     _items.clear();
//     notifyListeners();
//   }

//   double get totalAmount {
//     return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:vezigo/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class Cart with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
   int get totalItemsInCart {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

    void addItem(CartItem item) {
    final index = _items.indexWhere((i) => i.name == item.name && i.package == item.package);
    
    if (index != -1) {
      _items[index] = CartItem(
        name: _items[index].name,
        price: _items[index].price,
        quantity: _items[index].quantity + item.quantity,
        image: _items[index].image,
        package: _items[index].package,
      );
    } else {
      _items.add(item);
    }

    _saveCart(); 
    notifyListeners();
  }

   void updateItemQuantity(String name, int quantity, String packageId) {
    final index = _items.indexWhere((i) => i.name == name && i.package.id == packageId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = CartItem(
          name: _items[index].name,
          price: _items[index].price,
          quantity: quantity,
          image: _items[index].image,
          package: _items[index].package,
        );
      }

      
    }
  }
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken != null) {
      
      List<Map<String, dynamic>> cartItemsJson = _items.map((item) => item.toJson()).toList();
      prefs.setString('cart_$accessToken', jsonEncode(cartItemsJson));
    }
  }




   void removeItem(String name, String packageId) {
    _items.removeWhere((i) => i.name == name && i.package.id == packageId);

    _saveCart(); 
    notifyListeners();
  }


  void clearCart() {
    _items.clear();
    _saveCart(); 
    notifyListeners();
  }

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

   Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken != null) {
      final cartData = prefs.getString('cart_$accessToken');
      if (cartData != null) {
        List<dynamic> cartJson = jsonDecode(cartData);
        _items.clear();
        _items.addAll(cartJson.map((item) => CartItem.fromJson(item)).toList());
         _saveCart(); 
    
        notifyListeners();
      }
    }
  }
    
}



