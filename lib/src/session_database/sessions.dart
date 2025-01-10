
class Sessions {
  String id;
  int startTime;
  int endTime;

  Sessions({required this.id, required this.startTime, required this.endTime});

  // Convert Sessions object to a JSON map
  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime,
    'endTime': endTime,
  };

  // Create Sessions object from a JSON map
  factory Sessions.fromJson(Map<String, dynamic> json) {
    return Sessions(
      id: json['id'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}