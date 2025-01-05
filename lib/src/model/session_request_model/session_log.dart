
class SessionLog {
  String uniqueSessId;

  String contactId;
  String cookieId;
  String ipAddress;
  String sessionClosedAt;
  String sessionStartedAt;

  SessionLog({
    required this.uniqueSessId,

    required this.contactId,
    required this.cookieId,
    required this.ipAddress,
    required this.sessionClosedAt,
    required this.sessionStartedAt,
  });

  // fromJson method
  factory SessionLog.fromJson(Map<String, dynamic> json) {
    return SessionLog(
      uniqueSessId: json['uniqueSessId'],
      contactId: json['contactId'],
      cookieId: json['cookieId'],
      ipAddress: json['ipAddress'],
      sessionClosedAt: json['sessionClosedAt'],
      sessionStartedAt: json['sessionStartedAt'],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'uniqueSessId': uniqueSessId,
      'contactId': contactId,
      'cookieId': cookieId,
      'ipAddress': ipAddress,
      'sessionClosedAt': sessionClosedAt,
      'sessionStartedAt': sessionStartedAt,
    };
  }
}
