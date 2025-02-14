import 'constant.dart';

class Survey {
  String? baseUrl;
  String surveyToken;
  bool deviceDetails = true;
  Map<String, dynamic>? hashMap;

  Survey(this.surveyToken, String zfRegion) {
    if (surveyToken.isEmpty) {
      return;
    }

    baseUrl = _generateBaseUrl(surveyToken, zfRegion);
  }

  /// Method to set device details flag
  void sendDeviceDetails(bool deviceDetails) {
    this.deviceDetails = deviceDetails;
  }

  /// Method to get device details flag
  bool getDeviceDetails() {
    return deviceDetails;
  }

  /// Method to get the survey URL
  String getZfSurveyUrl() {
    String customVariableString = "?";
    return baseUrl! + customVariableString;
  }

  /// Method to get the survey token
  String getSurveyToken() {
    return surveyToken;
  }

  /// Method to send custom attributes
  void sendCustomAttributes(Map<String, dynamic> hashMap) {
    this.hashMap = hashMap;
  }

  /// Method to get custom attributes
  Map<String, dynamic>? getCustomAttributes() {
    return hashMap;
  }

  /// Private method to generate the base URL
  String _generateBaseUrl(String surveyToken, String zfRegion) {
    if (zfRegion.isNotEmpty && zfRegion.toUpperCase() == "EU") {
      return '${Constant.HTTPS}e${Constant.URL}$surveyToken';
    }
    if (zfRegion.isNotEmpty && zfRegion.toUpperCase() == "IN") {
      return '${Constant.HTTPS}in${Constant.URL}$surveyToken';
    }
    return '${Constant.HTTPS}us1${Constant.URL}$surveyToken';

    //  return 'https://s.zf2.zonkaplatform.com/$surveyToken';
  }
}
