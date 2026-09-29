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

  /// Coerces a JSON number into an [int].
  ///
  /// The backend stores these as numbers, but a value that round-trips through
  /// Mongo or JSON can arrive as a double (`5.0`) or a string (`"5"`). A raw
  /// cast would throw inside [Trigger.fromJson], and that exception is
  /// swallowed by the catch in `DataManager.hitSurveyActiveApi`, leaving the
  /// widget state unset and suppressing the survey entirely.
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  factory Trigger.fromJson(Map<String, dynamic> json) {
    return Trigger(
      after: _toInt(json['after']),
      scroll: _toInt(json['scroll']),
      url: json['url']?.toString(),
      keywords: json['keywords']?.toString(),
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
