class Devices {
  final bool? desktop;
  final bool? tablet;
  final bool? mobile;

  Devices({
    this.desktop,
    this.tablet,
    this.mobile,
  });

  /// Creates an instance from a JSON map.
  factory Devices.fromJson(Map<String, dynamic> json) {
    return Devices(
      desktop: json['desktop'] as bool?,
      tablet: json['tablet'] as bool?,
      mobile: json['mobile'] as bool?,
    );
  }

  /// Converts an instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'desktop': desktop,
      'tablet': tablet,
      'mobile': mobile,
    };
  }
}
