package com.example.zonkafeedback_sdk;

import android.content.Context;

import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.app.Application;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.os.Build;
import android.provider.Settings;


import androidx.annotation.NonNull;

import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** ZonkafeedbackSdkPlugin */
public class ZonkafeedbackSdkPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context context;
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "zonkafeedback_sdk");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }
    else if (call.method.equals("getAppVersionCode")) {
      String versionCode = getAppVersionCode(context);
      result.success(versionCode);
    }

    else if (call.method.equals("getDeviceSerial")) {
      String versionCode = getDeviceSerial();
      result.success(versionCode);
    }

    else if (call.method.equals("getDeviceName")) {
      String versionCode = getDeviceSerial();
      result.success(versionCode);
    }
    else if(call.method.equals("getScreenName")){
      String screenName = getScreenName(context);
      result.success(screenName);
    }
    else if(call.method.equals("getDeviceId")){
      String deviceId = getDeviceId(context);
      result.success(deviceId);
    }
    else if(call.method.equals("getModelName")){
      String modelName = getModelName();
      result.success(modelName);
    }
    else if(call.method.equals("getBrandName")){
      String brandName = getBrandName();
      result.success(brandName);
    }
    else if(call.method.equals("getIsTablet")){
      boolean  value  = isTablet(context);
      result.success(value);
    }
    else {
      result.notImplemented();
    }
  }

  public boolean isTablet(Context context) {
    boolean xlarge = ((context.getResources().getConfiguration().screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK) == 4);
    boolean large = ((context.getResources().getConfiguration().screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK) == Configuration.SCREENLAYOUT_SIZE_LARGE);
    return (xlarge || large);
  }
  public  String getBrandName(){
    return Build.BRAND;
  }
  public String getModelName(){
    return Build.MODEL;
  }

  public String getDeviceId(Context mContext) {
    @SuppressLint("HardwareIds") String android_id = Settings.Secure.getString(mContext.getContentResolver(), Settings.Secure.ANDROID_ID);
    if (android_id != null) {
      return android_id;
    } else {
      return " ";
    }
  }
  public String getScreenName(Context mContext) {
    ActivityManager result = (ActivityManager)mContext.getSystemService(Context.ACTIVITY_SERVICE);
    List<ActivityManager.RunningTaskInfo> services = result.getRunningTasks(Integer.MAX_VALUE);

    String screenName = "";
    try {
      screenName = services.get(0).topActivity.toString();
      screenName = screenName.substring(screenName.lastIndexOf('.') + 1).trim();
      screenName = screenName.replace("}","");
    } catch (Exception e) {
      e.printStackTrace();
    }
    return screenName;
  }

  public String getDeviceSerial() {
    final String Serial_No = Build.SERIAL;
    if (Serial_No != null) {
      return Serial_No;
    } else {
      return " ";
    }
  }


  public String getAppVersionCode(Context mContext) {
    int versionCode = 0;
    try {
      versionCode = mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0).versionCode;
    } catch (PackageManager.NameNotFoundException e) {
      e.printStackTrace();
    }
    return Integer.toString(versionCode);
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
