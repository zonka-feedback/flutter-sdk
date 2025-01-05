import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'zonka_sdk_method_channel.dart';

abstract class ZonkaSdkPlatform extends PlatformInterface {
  /// Constructs a ZonkaSdkPlatform.
  ZonkaSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZonkaSdkPlatform _instance = MethodChannelZonkaSdk();

  /// The default instance of [ZonkaSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelZonkaSdk].
  static ZonkaSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZonkaSdkPlatform] when
  /// they register themselves.
  static set instance(ZonkaSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Retrieves the platform version from the native platform.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  /// Retrieves the application version code from the native platform.
  Future<String?> getAppVersionCode() {
    throw UnimplementedError('getAppVersionCode() has not been implemented.');
  }

  /// Retrieves the device serial number from the native platform.
  Future<String?> getDeviceSerial() {
    throw UnimplementedError('getDeviceSerial() has not been implemented.');
  }

  /// Retrieves the device name from the native platform.
  Future<String?> getDeviceName() {
    throw UnimplementedError('getDeviceName() has not been implemented.');
  }

  /// Retrieves the current screen name from the native platform.
  Future<String?> getScreenName() {
    throw UnimplementedError('getScreenName() has not been implemented.');
  }
  Future<String?> getDeviceId() {
    throw UnimplementedError('getDeviceId() has not been implemented.');
  }

  /// Retrieves the current screen name from the native platform.
  Future<String?> getModelName() {
    throw UnimplementedError('getScreenName() has not been implemented.');
  }
  Future<String?> getBrandName() {
    throw UnimplementedError('getDeviceId() has not been implemented.');
  }

  Future<bool?> getIsTablet() {
    throw UnimplementedError('getDeviceId() has not been implemented.');
  }

}
