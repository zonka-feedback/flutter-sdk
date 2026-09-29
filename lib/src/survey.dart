import 'constant.dart';

class Survey {
  String? baseUrl;
  String surveyToken;
  bool deviceDetails = true;
  // Map<String, dynamic>? hashMap;

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

  /// Private method to generate the base URL
  String _generateBaseUrl(String surveyToken, String zfRegion) {
    if (zfRegion.isNotEmpty && zfRegion.toUpperCase() == "EU") {
      return '${Constant.https}e${Constant.url}$surveyToken';
    }
    if (zfRegion.isNotEmpty && zfRegion.toUpperCase() == "IN") {
      return '${Constant.https}in${Constant.url}$surveyToken';
    }
    return '${Constant.https}us1${Constant.url}$surveyToken';

    //  return 'https://s.zf2.zonkaplatform.com/$surveyToken';
  }
}
