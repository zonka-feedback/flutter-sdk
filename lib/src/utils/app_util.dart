import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import '../../zonka_sdk.dart';
import '../constant.dart';

class AppUtils {
  AppUtils._privateConstructor();

  static final AppUtils instance = AppUtils._privateConstructor();
  final _zonkaSdkPlugin = ZonkaSdk();

  /// Get Application Version Code
  Future<String?> getAppVersionCode() async {
    final packageInfo = await _zonkaSdkPlugin.getAppVersionCode();
    return packageInfo;
  }

  /// Get Device ID (ANDROID_ID)
  Future<String?> getDeviceId() async {
    var deviceInfo = await _zonkaSdkPlugin.getDeviceId();
    return deviceInfo;
  }

  /// Get Device Serial Number
  Future<String?> getDeviceSerial() async {
    var serialInfo = await _zonkaSdkPlugin.getDeviceSerial();
    return serialInfo;
  }

  Future<String?> getScreenName() async {
    var screenName = await _zonkaSdkPlugin.getScreenName();
    return screenName;
  }

  /// Get Device Resolution
  String getDeviceResolution(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width.toInt();
    final height = mediaQuery.size.height.toInt();
    return "${width}x$height";
  }

  /// Get Local IP Address
  Future<String> getLocalIpAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      rethrow;
    }
    return "N/A";
  }

  /// Get Network Type
  Future<String> getNetworkType() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.first == ConnectivityResult.mobile) {
      return "Mobile";
    } else if (connectivityResult.first == ConnectivityResult.wifi) {
      return "WIFI";
    } else {
      return "UNKNOWN";
    }
  }

  /// Check if device is Tablet
  bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600; // Consider devices >=600dp as tablets
  }

  /// Check if Network is Connected
  Future<bool> isNetworkConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.first != ConnectivityResult.none;
  }

  /// Calculate Time Difference in Seconds
  bool calculateDifferenceTime(int createdDateInMS) {
    final currentDateInMS = DateTime.now().millisecondsSinceEpoch;
    final difference = currentDateInMS - createdDateInMS;
    return (difference / 1000) <= 20;
  }

  /// Get Current Time in UTC or formatted
  String getCurrentTime(int timeStamp, String format) {
    final utcTime = DateTime.fromMillisecondsSinceEpoch(timeStamp).toUtc();
    final formatter = DateFormat(format);
    return formatter.format(utcTime);
  }

  /// Generate Random Cookie ID
  String getCookieId(int length) {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  String timeStampToDate(int timeStamp, String format) {
    // Convert the timestamp (milliseconds since epoch) to DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);

    // Format the DateTime using the specified format
    String formattedTime = DateFormat(format).format(dateTime);

    // Return the formatted time
    return formattedTime;
  }

  int getCurrentUtcTime(int timeStamp) {
    try {
      // Create a DateTime instance from the provided timestamp
      DateTime localDate = DateTime.fromMillisecondsSinceEpoch(timeStamp);

      // Format the date into UTC timezone
      DateFormat utcFormat = DateFormat("yyyy-MMM-dd HH:mm:ss");
      String utcDateString = utcFormat.format(localDate.toUtc());

      // Parse the UTC-formatted date back to a DateTime
      DateTime utcDateTime = utcFormat.parse(utcDateString);

      // Return UTC time in milliseconds since epoch
      return utcDateTime.millisecondsSinceEpoch;
    } catch (e) {
      return -1; // Return an error value
    }
  }

  /// Get Device Info HashMap Equivalent
  Future<Map<String, dynamic>> getHiddenVariables(BuildContext context) async {
    return {
      Constant.APP_VERSION_CODE: await getAppVersionCode(),
      Constant.DEVICE_RESOLUTION: getDeviceResolution(context),
      Constant.DEVICE_SERIAL: await getDeviceSerial(),
      Constant.GET_NETWORK: await getNetworkType(),
      Constant.DEVICE_NAME: await _zonkaSdkPlugin.getDeviceName(),
      Constant.DEVICE_MODEL: await _zonkaSdkPlugin.getModelName(),
      Constant.DEVICE_BRAND: await _zonkaSdkPlugin.getBrandName(),
      Constant.TIME_ZONE: DateTime.now().timeZoneName,
      Constant.DEVICE_TYPE: isTablet(context) ? "Tablet" : "Mobile",
      Constant.DEVICE_OS: Platform.isIOS ? Constant.IOS : Constant.ANDROID,
      Constant.DEVICE_OS_VERSION: Platform.operatingSystemVersion,
      Constant.SCREEN_NAME: await getScreenName(),
      Constant.APP_VERSION_NAME: "1.0"
    };
  }
}
