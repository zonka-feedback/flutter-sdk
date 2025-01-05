
class Data {
  List<String>? savedUniqueSessions;
  Data({this.savedUniqueSessions});

  // Factory constructor for creating an instance from JSON
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      savedUniqueSessions: json['savedUniqueSessions'] != null
          ? List<String>.from(json['savedUniqueSessions'])
          : null,
    );
  }

  // Converts the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'savedUniqueSessions': savedUniqueSessions,
    };
  }


}
