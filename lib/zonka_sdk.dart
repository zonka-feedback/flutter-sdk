import 'zonka_sdk_platform_interface.dart';

class ZonkaSdk {
  /// Retrieves the platform version.
  Future<String?> getPlatformVersion() {
    return ZonkaSdkPlatform.instance.getPlatformVersion();
  }

  /// Retrieves the application version code.
  Future<String?> getAppVersionCode() {
    return ZonkaSdkPlatform.instance.getAppVersionCode();
  }

  /// Retrieves the device serial number.
  Future<String?> getDeviceSerial() {
    return ZonkaSdkPlatform.instance.getDeviceSerial();
  }

  /// Retrieves the device name.
  Future<String?> getDeviceName() {
    return ZonkaSdkPlatform.instance.getDeviceName();
  }

  /// Retrieves the current screen name.
  Future<String?> getScreenName() {
    return ZonkaSdkPlatform.instance.getScreenName();
  }


  Future<String?> getDeviceId() {
    return ZonkaSdkPlatform.instance.getDeviceId();
  }

  /// Retrieves the current screen name.
  Future<String?> getModelName() {
    return ZonkaSdkPlatform.instance.getModelName();
  }


  Future<String?> getBrandName() {
    return ZonkaSdkPlatform.instance.getBrandName();
  }

  Future<bool?> getIsTablet() {
    return ZonkaSdkPlatform.instance.getIsTablet();
  }
}
