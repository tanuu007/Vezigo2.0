import 'package:vezigo/Api_Models/product_detail.dart';
class CartItem {
  final String name;
  final double price;
  final int quantity;
  final String image;
  final Package package;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.package,
  });

  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
      'package': package.toJson(), 
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      image: json['image'],
      package: Package.fromJson(json['package']), 
    );
  }
}

