

class OrderDetailRes {
  final int code;
  final String message;
  final OrderDetailData data;

  OrderDetailRes({
    required this.code,
    required this.message,
    required this.data,
  });

  factory OrderDetailRes.fromJson(Map<String, dynamic> json) {
    return OrderDetailRes(
      code: json['code'],
      message: json['message'],
      data: OrderDetailData.fromJson(json['data']),
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

class OrderDetailData {
  final UserDetails userDetails;
  final List<Item> items;
  final String billAmount;
  final Geo geo;
  final DateTime createdAt;
  final String id;

  OrderDetailData({
    required this.userDetails,
    required this.items,
    required this.billAmount,
    required this.geo,
    required this.createdAt,
    required this.id,
  });

  factory OrderDetailData.fromJson(Map<String, dynamic> json) {
    return OrderDetailData(
      userDetails: UserDetails.fromJson(json['userDetails']),
      items: (json['items'] as List)
          .map((item) => Item.fromJson(item))
          .toList(),
      billAmount: json['billAmount'],
      geo: Geo.fromJson(json['geo']),
      createdAt: DateTime.parse(json['createdAt']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userDetails': userDetails.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'billAmount': billAmount,
      'geo': geo.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'id': id,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'notes': notes,
      'address': address,
      'name': name,
      'altPhoneNumber': altPhoneNumber,
      'phoneNumber': phoneNumber,
    };
  }
}

class Item {
  final Pack pack;
  final Product product;
  final int quantity;

  Item({
    required this.pack,
    required this.product,
    required this.quantity,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      pack: Pack.fromJson(json['pack']),
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pack': pack.toJson(),
      'product': product.toJson(),
      'quantity': quantity,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'unit': unit,
      'quantity': quantity,
    };
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
  final List<Package> packages;
  final DateTime createdAt;
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
          .map((pkg) => Package.fromJson(pkg))
          .toList(),
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
      'packages': packages.map((pkg) => pkg.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'id': id,
    };
  }
}

class Package {
  final String id;
  final int quantity;
  final String unit;
  final int price;

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

class Geo {
  final double lat;
  final double lng;

  Geo({
    required this.lat,
    required this.lng,
  });

  factory Geo.fromJson(Map<String, dynamic> json) {
    return Geo(
      lat: json['lat'],
      lng: json['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}
