class BannersResponse {
  int code;
  String message;
  BannerData data;

  BannersResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory BannersResponse.fromJson(Map<String, dynamic> json) {
    return BannersResponse(
      code: json['code'],
      message: json['message'],
      data: BannerData.fromJson(json['data']),
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

class BannerData {
  List<BannerItem> results;

  BannerData({
    required this.results,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List;
    List<BannerItem> resultsList =
        list.map((i) => BannerItem.fromJson(i)).toList();
    return BannerData(results: resultsList);
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((item) => item.toJson()).toList(),
    };
  }
}

class BannerItem {
  String title;
  String subtitle;
  String image;
  String url;

  BannerItem({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.url,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      title: json['title'],
      subtitle: json['subtitle'],
      image: json['image'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'url': url,
    };
  }
}
