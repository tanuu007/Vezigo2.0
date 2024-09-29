class GetProfile {
  int code;
  String message;
  ProfileData data;
 GetProfile({
    required this.code,
    required this.message,
    required this.data,
  });


  factory GetProfile.fromJson(Map<String, dynamic> json) {
    return GetProfile(
      code: json['code'],
      message: json['message'],
      data: ProfileData.fromJson(json['data']),
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

class ProfileData {
  bool isPhoneNumberVerified;
  bool isBlocked;
  List<dynamic> favorites;
  List<dynamic> orders;
  String role;
  String address;
  String name;
  String phoneNumber;
  String createdAt;
  List<dynamic> addresses;
  String id;

  ProfileData({
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
    required this.id,
  });

 
  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
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
      'id': id,
    };
  }
}

