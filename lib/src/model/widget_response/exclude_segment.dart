class ExcludeSegment {
  String? type;
  List<String>? list;

  ExcludeSegment({this.type, this.list});

  factory ExcludeSegment.fromJson(Map<String, dynamic> json) {
    return ExcludeSegment(
      type: json['type'],
      list: json['list'] != null ? List<String>.from(json['list']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'list': list,
    };
  }
}
