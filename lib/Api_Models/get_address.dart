class AddressResponse {
  int? code;
  String? message;
  Data? data;

  AddressResponse({this.code, this.message, this.data});

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Result>? results;

  Data({this.results});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      results: json['results'] != null
          ? (json['results'] as List)
              .map((item) => Result.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (results != null) {
      data['results'] = results!.map((item) => item.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String? text;
  String? description;
  String? label;
  String? user;
  String? createdAt;
  String? id;

  Result(
      {this.text,
      this.description,
      this.label,
      this.user,
      this.createdAt,
      this.id});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      text: json['text'],
      description: json['description'],
      label: json['label'],
      user: json['user'],
      createdAt: json['createdAt'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['text'] = text;
    data['description'] = description;
    data['label'] = label;
    data['user'] = user;
    data['createdAt'] = createdAt;
    data['id'] = id;
    return data;
  }
}
