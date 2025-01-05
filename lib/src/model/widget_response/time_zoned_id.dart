

class TimeZoneId {
  String? timeZone;
  String? displayName;
  String? tzOffset;
  String? id;
  int? preMongifiedId;
  String? tzOffsetSec;
  String? createdDate;
  String? modifiedDate;

  TimeZoneId({
    this.timeZone,
    this.displayName,
    this.tzOffset,
    this.id,
    this.preMongifiedId,
    this.tzOffsetSec,
    this.createdDate,
    this.modifiedDate,
  });

  factory TimeZoneId.fromJson(Map<String, dynamic> json) {
    return TimeZoneId(
      timeZone: json['timeZone'],
      displayName: json['displayName'],
      tzOffset: json['tzOffset'],
      id: json['_id'],
      preMongifiedId: json['pre_mongified_id'],
      tzOffsetSec: json['tzOffsetSec'],
      createdDate: json['createdDate'],
      modifiedDate: json['modifiedDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeZone': timeZone,
      'displayName': displayName,
      'tzOffset': tzOffset,
      '_id': id,
      'pre_mongified_id': preMongifiedId,
      'tzOffsetSec': tzOffsetSec,
      'createdDate': createdDate,
      'modifiedDate': modifiedDate,
    };
  }
}
