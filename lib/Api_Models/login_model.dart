
class LoginRequest {
  final String countryCode;
  final String phoneNumber;

  LoginRequest({
    required this.countryCode,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
    };
  }
}

class LoginResponse {
  final int code;
  final String message;
  final int data;

  LoginResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'],
    );
  }
}
