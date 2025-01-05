

import './data.dart';

class ContactResponse {
  ContactResponse({
    this.status,
    this.success,
    this.message,
    this.data,
    this.err,
  });

  int? status;
  bool? success;
  String? message;
  Data? data;
  String? err;

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      status: json['status'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      err: json['err'] as String?,
    );
  }

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

