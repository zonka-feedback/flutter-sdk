
import 'contact_info.dart';
import 'evd.dart';

class Data {
  ContactInfo? contactInfo;
  Evd ? evd;

  Data({
    required this.contactInfo,
    required this.evd,
  });

  // Manual fromJson method
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      contactInfo:json['contactInfo'] != null && json['contactInfo'] != "" ?  ContactInfo.fromJson(json['contactInfo']) : null,
      evd:json['evd'] != null  && json['evd'] != ""?  Evd.fromJson(json['evd']) : null,
    );
  }

  // Manual toJson method
  Map<String, dynamic> toJson() {
    return {
      'contactInfo': contactInfo?.toJson(),
      'evd': evd?.toJson(),
    };
  }
}
