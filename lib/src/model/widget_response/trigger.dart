
class Trigger {
  int? after;
  int? scroll;
  String? url;
  String? keywords;

  Trigger({
    this.after,
    this.scroll,
    this.url,
    this.keywords,
  });

  factory Trigger.fromJson(Map<String, dynamic> json) {
    return Trigger(
      after: json['after'],
      scroll: json['scroll'],
      url: json['url'],
      keywords: json['keywords'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'after': after,
      'scroll': scroll,
      'url': url,
      'keywords': keywords,
    };
  }
}
