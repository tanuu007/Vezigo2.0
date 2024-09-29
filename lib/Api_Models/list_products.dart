
class Product {
  final String id;
  final String title;
  final String marketPrice;
  final String imageUrl;
  final bool inStock;
  final bool organic;
  final String description;
  

  Product({
    required this.id,
    required this.title,
    required this.marketPrice,
    required this.imageUrl,
    required this.inStock,
    required this.organic,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      marketPrice: json['marketPrice'] as String,
      imageUrl: json['imageUrl'] as String,
      inStock: json['inStock'] as bool,
      organic: json['organic'] as bool,
      description: json['description'] as String,
    );
  }
}


class Package {
  final String id;
  final int quantity;
  final String unit;
  final double price;

  Package({
    required this.id,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['_id'],
      quantity: json['quantity'],
      unit: json['unit'],
      price: json['price'].toDouble(),
    );
  }
}


