

import 'distribution_info.dart';
import 'company_info.dart';

class Data {
  final DistributionInfo? distributionInfo;
  final CompanyInfo? companyInfo;
  final dynamic contactInfo;

  Data({
    this.distributionInfo,
    this.companyInfo,
    this.contactInfo,
  });

  /// Creates an instance from a JSON map.
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      distributionInfo: json['distributionInfo'] != null
          ? DistributionInfo.fromJson(json['distributionInfo'])
          : null,
      companyInfo: json['companyInfo'] != null
          ? CompanyInfo.fromJson(json['companyInfo'])
          : null,
      contactInfo: json['contactInfo'], // Left as dynamic for flexibility.
    );
  }

  /// Converts an instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'distributionInfo': distributionInfo?.toJson(),
      'companyInfo': companyInfo?.toJson(),
      'contactInfo': contactInfo,
    };
  }
}
