

import '../contact_response/data.dart';

class SessionResponse {
  int? status;
  bool? success;
  String? message;
  Data? data;
  String? err;

  SessionResponse({
    this.status,
    this.success,
    this.message,
    this.data,
    this.err,
  });

  // Factory constructor for creating an instance from JSON
  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      status: json['status'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      err: json['err'] as String?,
    );
  }

  // Converts the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'err': err,
    };
  }

}

