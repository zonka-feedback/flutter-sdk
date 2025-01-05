
import '../widget_response/data.dart';

class WidgetResponse {
  final int? status;
  final bool? success;
  final String? message;
  final Data? data;
  final String? err;

  WidgetResponse({
    this.status,
    this.success,
    this.message,
    this.data,
    this.err,
  });

  /// Factory method to create a `Widget` object from a JSON map.
  factory WidgetResponse.fromJson(Map<String, dynamic> json) {
    return WidgetResponse(
      status: json['status'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? Data.fromJson(json['data'] as Map<String, dynamic>) : null,
      err: json['err'] as String?,
    );
  }

  /// Method to convert a `Widget` object to a JSON map.
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



