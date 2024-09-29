

class SignupRequest {
  final String name;
  final String countryCode;
  final String phoneNumber;

  SignupRequest({
    required this.name,
    required this.countryCode,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
    };
  }
}

class SignupResponse {
  final int code;
  final String message;
  final int data;

  SignupResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'],
    );
  }
}
