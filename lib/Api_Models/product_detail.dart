class ProductResponse {
  int code;
  String message;
  ProductData data;

  ProductResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      code: json['code'],
      message: json['message'],
      data: ProductData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ProductData {
  String description;
  String currency;
  bool organic;
  bool inStock;
  String title;
  String category;
  String marketPrice;
  String imageUrl;
  List<Package> packages;
  DateTime createdAt;
  String id;

  ProductData({
    required this.description,
    required this.currency,
    required this.organic,
    required this.inStock,
    required this.title,
    required this.category,
    required this.marketPrice,
    required this.imageUrl,
    required this.packages,
    required this.createdAt,
    required this.id,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      description: json['description'],
      currency: json['currency'],
      organic: json['organic'],
      inStock: json['inStock'],
      title: json['title'],
      category: json['category'],
      marketPrice: json['marketPrice'],
      imageUrl: json['imageUrl'],
      packages: List<Package>.from(json['packages'].map((p) => Package.fromJson(p))),
      createdAt: DateTime.parse(json['createdAt']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'currency': currency,
      'organic': organic,
      'inStock': inStock,
      'title': title,
      'category': category,
      'marketPrice': marketPrice,
      'imageUrl': imageUrl,
      'packages': packages.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'id': id,
    };
  }
}

class Package {
  String id;
  int quantity;
  String unit;
  int price;

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
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'quantity': quantity,
      'unit': unit,
      'price': price,
    };
  }
}
