class EventRequest {
  String? ipAddress;
  String? surveyRefCode;
  String? externalVisitorId;
  String? contactId;
  String? device;
  String? deviceOS;
  String? deviceOSVersion;
  String? deviceSerialNumber;
  String? deviceName;
  String? deviceModel;
  String? deviceBrand;

  EventRequest({
    this.ipAddress,
    this.surveyRefCode,
    this.externalVisitorId,
    this.contactId,
    this.device,
    this.deviceOS,
    this.deviceOSVersion,
    this.deviceSerialNumber,
    this.deviceName,
    this.deviceModel,
    this.deviceBrand,
  });

  // Convert from JSON
  factory EventRequest.fromJson(Map<String, dynamic> json) {
    return EventRequest(
      ipAddress: json['ipAddress'],
      surveyRefCode: json['surveyRefCode'],
      externalVisitorId: json['externalVisitorId'],
      contactId: json['contactId'],
      device: json['device'],
      deviceOS: json['deviceOS'],
      deviceOSVersion: json['deviceOSVersion'],
      deviceSerialNumber: json['deviceSerialNumber'],
      deviceName: json['deviceName'],
      deviceModel: json['deviceModel'],
      deviceBrand: json['deviceBrand'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ipAddress': ipAddress,
      'surveyRefCode': surveyRefCode,
      'externalVisitorId': externalVisitorId,
      'contactId': contactId,
      'device': device,
      'deviceOS': deviceOS,
      'deviceOSVersion': deviceOSVersion,
      'deviceSerialNumber': deviceSerialNumber,
      'deviceName': deviceName,
      'deviceModel': deviceModel,
      'deviceBrand': deviceBrand,
    };
  }
}
