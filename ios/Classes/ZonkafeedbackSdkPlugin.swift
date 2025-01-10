import Flutter
import UIKit

public class ZonkafeedbackSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "zonkafeedback_sdk", binaryMessenger: registrar.messenger())
    let instance = ZonkafeedbackSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
      
    case "getAppVersionCode":
      result(getAppVersionCode())
      
    case "getDeviceSerial":
      result(getDeviceSerial())
      
    case "getDeviceName":
      result(getDeviceName())
      
    case "getScreenName":
      result(getScreenName())
      
    case "getDeviceId":
      result(getDeviceId())
      
    case "getModelName":
      result(getModelName())
      
    case "getBrandName":
      result(getBrandName())
      
    case "getIsTablet":
      result(isTablet())
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getAppVersionCode() -> String {
    guard let info = Bundle.main.infoDictionary,
          let version = info["CFBundleVersion"] as? String else {
      return "Unknown"
    }
    return version
  }

  private func getDeviceSerial() -> String {
    // iOS does not expose serial number for privacy reasons.
    return "Unavailable (Restricted)"
  }

  private func getDeviceName() -> String {
    return UIDevice.current.name
  }

  private func getScreenName() -> String {
    guard let topViewController = UIApplication.shared.windows.first?.rootViewController else {
      return "Unknown"
    }
    return String(describing: type(of: topViewController))
  }

  private func getDeviceId() -> String {
    if let identifier = UIDevice.current.identifierForVendor?.uuidString {
      return identifier
    } else {
      return "Unknown"
    }
  }

  private func getModelName() -> String {
    return UIDevice.current.model
  }

  private func getBrandName() -> String {
    return "Apple"
  }

  private func isTablet() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
  }
}
