import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'zonka_sdk_platform_interface.dart';

/// An implementation of [ZonkaSdkPlatform] that uses method channels.

/// An implementation of [ZonkaSdkPlatform] that uses method channels.
class MethodChannelZonkaSdk extends ZonkaSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zonkafeedback_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    try {
      final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
      return version;
    } on PlatformException catch (e) {
      debugPrint('Failed to get platform version: ${e.message}');
      return null;
    }
  }

  /// Gets the application version code from the native platform.
  @override
  Future<String?> getAppVersionCode() async {
    try {
      final versionCode = await methodChannel.invokeMethod<String>('getAppVersionCode');
      return versionCode;
    } on PlatformException catch (e) {
      debugPrint('Failed to get app version code: ${e.message}');
      return null;
    }
  }

  /// Gets the device's serial number.
  @override
  Future<String?> getDeviceSerial() async {
    try {
      final serial = await methodChannel.invokeMethod<String>('getDeviceSerial');
      return serial;
    } on PlatformException catch (e) {
      debugPrint('Failed to get device serial: ${e.message}');
      return null;
    }
  }

  /// Gets the device name.
  @override
  Future<String?> getDeviceName() async {
    try {
      final deviceName = await methodChannel.invokeMethod<String>('getDeviceName');
      return deviceName;
    } on PlatformException catch (e) {
      debugPrint('Failed to get device name: ${e.message}');
      return null;
    }
  }

  /// Gets the currently active screen name from the native platform.
  @override
  Future<String?> getScreenName() async {
    try {
      final screenName = await methodChannel.invokeMethod<String>('getScreenName');
      return screenName;
    } on PlatformException catch (e) {
      debugPrint('Failed to get screen name: ${e.message}');
      return null;
    }
  }

  @override
  Future<String?> getDeviceId() async {
    try {
      final screenName = await methodChannel.invokeMethod<String>('getDeviceId');
      return screenName;
    } on PlatformException catch (e) {
      debugPrint('Failed to get device id: ${e.message}');
      return null;
    }
  }

  @override
  Future<String?> getModelName() async {
    try {
      final modelName = await methodChannel.invokeMethod<String>('getModelName');
      return modelName;
    } on PlatformException catch (e) {
      debugPrint('Failed to get device id: ${e.message}');
      return null;
    }
  }
  @override
  Future<String?> getBrandName() async {
    try {
      final brandName = await methodChannel.invokeMethod<String>('getBrandName');
      return brandName;
    } on PlatformException catch (e) {
      debugPrint('Failed to get device id: ${e.message}');
      return null;
    }
  }

  @override
  Future<bool?> getIsTablet() async {
    try {
      final brandName = await methodChannel.invokeMethod<bool>('getIsTablet');
      return brandName;
    } on PlatformException catch (e) {
      debugPrint('Failed to get device id: ${e.message}');
      return null;
    }
  }


}

