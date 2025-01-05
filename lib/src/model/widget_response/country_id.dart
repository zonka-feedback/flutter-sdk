
class CountryId {
  final String? name;
  final String? shortName;
  final String? phoneCode;
  final double? credits;
  final int? startWeekDay;
  final String? id;
  final int? preMongifiedId;
  final String? createdDate;
  final String? modifiedDate;

  CountryId({
    this.name,
    this.shortName,
    this.phoneCode,
    this.credits,
    this.startWeekDay,
    this.id,
    this.preMongifiedId,
    this.createdDate,
    this.modifiedDate,
  });

  /// Creates an instance from a JSON map.
  factory CountryId.fromJson(Map<String, dynamic> json) {
    return CountryId(
      name: json['name'],
      shortName: json['shortName'],
      phoneCode: json['phoneCode'],
      credits: (json['credits'] as num?)?.toDouble(),
      startWeekDay: json['startWeekDay'],
      id: json['_id'],
      preMongifiedId: json['pre_mongified_id'],
      createdDate: json['createdDate'],
      modifiedDate: json['modifiedDate'],
    );
  }

  /// Converts an instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shortName': shortName,
      'phoneCode': phoneCode,
      'credits': credits,
      'startWeekDay': startWeekDay,
      '_id': id,
      'pre_mongified_id': preMongifiedId,
      'createdDate': createdDate,
      'modifiedDate': modifiedDate,
    };
  }
}
