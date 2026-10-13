import 'widget_response/distribution_info.dart';

/// One entry of the `distribution/validateCodes` response.
class TokenValidation {
  final String token;
  final bool valid;

  /// Present only for a token that validated.
  final DistributionInfo? distributionInfo;

  TokenValidation({
    required this.token,
    required this.valid,
    this.distributionInfo,
  });

  factory TokenValidation.fromJson(Map<String, dynamic> json) {
    final dynamic info = json['distributionInfo'];
    return TokenValidation(
      token: json['token']?.toString() ?? '',
      valid: json['valid'] == true,
      distributionInfo: info is Map
          ? DistributionInfo.fromJson(Map<String, dynamic>.from(info))
          : null,
    );
  }
}
