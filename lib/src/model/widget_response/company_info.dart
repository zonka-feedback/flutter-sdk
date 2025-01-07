import 'package:zonkafeedback_sdk/src/model/widget_response/time_zoned_id.dart';

import 'country_id.dart';

class CompanyInfo {
  final CountryId? countryId;
  final TimeZoneId? timeZoneId;
  final bool? isActive;
  final bool? isDeleted;
  final bool? surveyWhiteLabelDomainValid;
  final String? surveyWhiteLabelDomain;
  final String? id;
  final int? preMongifiedId;

  CompanyInfo({
    this.countryId,
    this.timeZoneId,
    this.isActive,
    this.isDeleted,
    this.surveyWhiteLabelDomainValid,
    this.surveyWhiteLabelDomain,
    this.id,
    this.preMongifiedId,
  });

  /// Creates an instance from a JSON map.
  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      countryId: json['countryId'] != null
          ? CountryId.fromJson(json['countryId'])
          : null,
      timeZoneId: json['timeZoneId'] != null
          ? TimeZoneId.fromJson(json['timeZoneId'])
          : null,
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
      surveyWhiteLabelDomainValid: json['surveyWhiteLabelDomainValid'],
      surveyWhiteLabelDomain: json['surveyWhiteLabelDomain'],
      id: json['_id'],
      preMongifiedId: json['pre_mongified_id'],
    );
  }

  /// Converts an instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'countryId': countryId?.toJson(),
      'timeZoneId': timeZoneId?.toJson(),
      'isActive': isActive,
      'isDeleted': isDeleted,
      'surveyWhiteLabelDomainValid': surveyWhiteLabelDomainValid,
      'surveyWhiteLabelDomain': surveyWhiteLabelDomain,
      '_id': id,
      'pre_mongified_id': preMongifiedId,
    };
  }
}
