

import 'package:zonkafeedback_sdk/src/model/session_request_model/session_log.dart';

class UpdateSessionRequest {
  String? deviceType;
  List<SessionLog>? sessionLogs;

  UpdateSessionRequest({
     this.deviceType,
     this.sessionLogs,
  });

  // fromJson method
  factory UpdateSessionRequest.fromJson(Map<String, dynamic> json) {
    return UpdateSessionRequest(
      deviceType: json['deviceType'],
      sessionLogs: (json['sessionLogs'] as List)
          .map((log) => SessionLog.fromJson(log))
          .toList(),
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'deviceType': deviceType,
      'sessionLogs': sessionLogs?.map((log) => log.toJson()).toList(),
    };
  }
}
