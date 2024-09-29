class OrdersResponse {
  final int code;
  final String message;
  final Data data;

  OrdersResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      code: json['code'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final List<Order> results;
  final int page;
  final int limit;
  final int totalPages;
  final int totalResults;

  Data({
    required this.results,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalResults,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      results: (json['results'] as List).map((item) => Order.fromJson(item)).toList(),
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
      totalResults: json['totalResults'],
    );
  }
}

class Order {
  final UserDetails userDetails;
  final List<OrderItem> items;
  final String billAmount;
  final Geo? geo;  // Geo can also be null
  final String createdAt;
  final String id;

  Order({
    required this.userDetails,
    required this.items,
    required this.billAmount,
    required this.geo,
    required this.createdAt,
    required this.id,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      userDetails: UserDetails.fromJson(json['userDetails']),
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      billAmount: json['billAmount'],
      geo: json['geo'] != null ? Geo.fromJson(json['geo']) : null,  // Handle null case for 'geo'
      createdAt: json['createdAt'],
      id: json['id'],
    );
  }
}


class UserDetails {
  final String notes;
  final String address;
  final String name;
  final String altPhoneNumber;
  final String phoneNumber;

  UserDetails({
    required this.notes,
    required this.address,
    required this.name,
    required this.altPhoneNumber,
    required this.phoneNumber,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      notes: json['notes'],
      address: json['address'],
      name: json['name'],
      altPhoneNumber: json['altPhoneNumber'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

class OrderItem {
  final Pack pack;
  final Product? product;  // Marking as nullable
  final int quantity;

  OrderItem({
    required this.pack,
    required this.product,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      pack: Pack.fromJson(json['pack']),
      product: json['product'] != null 
        ? Product.fromJson(json['product']) 
        : null,  // Handle null case for 'product'
      quantity: json['quantity'],
    );
  }
}

class Pack {
  final int price;
  final String unit;
  final int quantity;

  Pack({
    required this.price,
    required this.unit,
    required this.quantity,
  });

  factory Pack.fromJson(Map<String, dynamic> json) {
    return Pack(
      price: json['price'],
      unit: json['unit'],
      quantity: json['quantity'],
    );
  }
}

class Product {
  final String description;
  final String currency;
  final bool organic;
  final bool inStock;
  final String title;
  final String category;
  final String marketPrice;
  final String imageUrl;
  final List<ProductPackage> packages;
  final String createdAt;
  final String id;

  Product({
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      description: json['description'],
      currency: json['currency'],
      organic: json['organic'],
      inStock: json['inStock'],
      title: json['title'],
      category: json['category'],
      marketPrice: json['marketPrice'],
      imageUrl: json['imageUrl'],
      packages: (json['packages'] as List)
          .map((item) => ProductPackage.fromJson(item))
          .toList(),
      createdAt: json['createdAt'],
      id: json['id'],
    );
  }
}

class ProductPackage {
  final String id;
  final int quantity;
  final String unit;
  final int price;

  ProductPackage({
    required this.id,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  factory ProductPackage.fromJson(Map<String, dynamic> json) {
    return ProductPackage(
      id: json['_id'],
      quantity: json['quantity'],
      unit: json['unit'],
      price: json['price'],
    );
  }
}

class Geo {
  final double lat;
  final double lng;

  Geo({
    required this.lat,
    required this.lng,
  });

  factory Geo.fromJson(Map<String, dynamic> json) {
    return Geo(
      lat: json['lat'] is String ? double.parse(json['lat']) : json['lat'].toDouble(),
      lng: json['lng'] is String ? double.parse(json['lng']) : json['lng'].toDouble(),
    );
  }
}
