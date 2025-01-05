

class IncludeSegment {
  List<String>? list;
  String? type;

  IncludeSegment({this.list, this.type});

  factory IncludeSegment.fromJson(Map<String, dynamic> json) {
    return IncludeSegment(
      list: json['list'] != null ? List<String>.from(json['list']) : null,
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list,
      'type': type,
    };
  }
}
