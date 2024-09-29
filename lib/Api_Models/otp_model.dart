class OtpResponse {
  final int code;
  final String phone;
  final UserData data;

  OtpResponse({
    required this.code,
    required this.phone,
    required this.data,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      code: json['code'],
      phone: json['message'],
      data: UserData.fromJson(json['data']),
    );
  }
}

class UserData {
  final User user;
  final Tokens tokens;

  UserData({
    required this.user,
    required this.tokens,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: User.fromJson(json['user']),
      tokens: Tokens.fromJson(json['tokens']),
    );
  }
}

class User {
  final bool isPhoneNumberVerified;
  final bool isBlocked;
  final List<dynamic> favorites;
  final List<dynamic> orders;
  final String role;
  final String address;
  final String name;
  final String phoneNumber;
  final String createdAt;
  final String id;

  User({
    required this.isPhoneNumberVerified,
    required this.isBlocked,
    required this.favorites,
    required this.orders,
    required this.role,
    required this.address,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
    required this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      isPhoneNumberVerified: json['isPhoneNumberVerified'],
      isBlocked: json['isBlocked'],
      favorites: json['favorites'] ?? [],
      orders: json['orders'] ?? [],
      role: json['role'],
      address: json['address'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      createdAt: json['createdAt'],
      id: json['id'],
    );
  }
}

class Tokens {
  final AccessToken access;
  final RefreshToken refresh;

  Tokens({
    required this.access,
    required this.refresh,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      access: AccessToken.fromJson(json['access']),
      refresh: RefreshToken.fromJson(json['refresh']),
    );
  }
}

class AccessToken {
  final String token;
  final String expires;

  AccessToken({
    required this.token,
    required this.expires,
  });

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(
      token: json['token'],
      expires: json['expires'],
    );
  }
}

class RefreshToken {
  final String token;
  final String expires;

  RefreshToken({
    required this.token,
    required this.expires,
  });

  factory RefreshToken.fromJson(Map<String, dynamic> json) {
    return RefreshToken(
      token: json['token'],
      expires: json['expires'],
    );
  }
}
