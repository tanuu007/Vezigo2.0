class UserModel {
  final int code;
  final String message;
  final UserData data;

  UserModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      code: json['code'],
      message: json['message'],
      data: UserData.fromJson(json['data']),
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

class UserData {
  final bool isPhoneNumberVerified;
  final bool isBlocked;
  final List<dynamic> favorites;
  final List<dynamic> orders;
  final String role;
  final String address;
  final String name;
  final String phoneNumber;
  final String createdAt;
  final List<dynamic> addresses;
  final String email;
  final String id;

  UserData({
    required this.isPhoneNumberVerified,
    required this.isBlocked,
    required this.favorites,
    required this.orders,
    required this.role,
    required this.address,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
    required this.addresses,
    required this.email,
    required this.id,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      isPhoneNumberVerified: json['isPhoneNumberVerified'],
      isBlocked: json['isBlocked'],
      favorites: List<dynamic>.from(json['favorites']),
      orders: List<dynamic>.from(json['orders']),
      role: json['role'],
      address: json['address'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      createdAt: json['createdAt'],
      addresses: List<dynamic>.from(json['addresses']),
      email: json['email'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPhoneNumberVerified': isPhoneNumberVerified,
      'isBlocked': isBlocked,
      'favorites': favorites,
      'orders': orders,
      'role': role,
      'address': address,
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'addresses': addresses,
      'email': email,
      'id': id,
    };
  }
}
