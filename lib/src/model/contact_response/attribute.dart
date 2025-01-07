class Attribute {
  String? id;
  String? value;
  String? field5e12d8c8ee2f084102f1ccc2; // Use a valid Dart variable name
  String? contactCountry;
  String? type;

  Attribute({
    this.id,
    this.value,
    this.field5e12d8c8ee2f084102f1ccc2,
    this.contactCountry,
    this.type,
  });

  // Factory constructor to create an instance from JSON
  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'] as String?,
      value: json['value'] as String?,
      field5e12d8c8ee2f084102f1ccc2:
          json['5e12d8c8ee2f084102f1ccc2'] as String?,
      contactCountry: json['contact_country'] as String?,
      type: json['type'] as String?,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      '5e12d8c8ee2f084102f1ccc2': field5e12d8c8ee2f084102f1ccc2,
      'contact_country': contactCountry,
      'type': type,
    };
  }
}
