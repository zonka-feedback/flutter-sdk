import 'dart:convert';

class PagesViewedLog {
  String? url;
  String? title;
  String? path;
  String? referal;

  PagesViewedLog({
    this.url,
    this.title,
    this.path,
    this.referal,
  });

  // Factory constructor for creating an instance from JSON
  factory PagesViewedLog.fromJson(Map<String, dynamic> json) {
    return PagesViewedLog(
      url: json['url'] as String?,
      title: json['title'] as String?,
      path: json['path'] as String?,
      referal: json['referal'] as String?,
    );
  }

  // Converts the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'path': path,
      'referal': referal,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
