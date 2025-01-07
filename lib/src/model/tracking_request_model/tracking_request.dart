import 'package:zonkafeedback_sdk/src/model/tracking_request_model/page_viewed_log.dart';

class TrackingRequest {
  String? workSpaceId;
  String? companyId;
  String? cookieId;
  String? sessCookieId;
  String? firstPageQStr;
  String? firstSeen;
  String? firstPage;
  List<String>? pagesViewed;
  List<PagesViewedLog>? pagesViewedLogs;
  String? firstReferringSite;
  String? firstUserAgent;
  String? firstBrowserLanguage;
  String? firstDevice;
  String? firstScreenSize;
  String? lastSeen;
  String? lastPage;
  String? lastReferringSite;
  String? lastUserAgent;
  String? lastDevice;
  String? lastScreenSize;
  String? lastBrowserLanguage;
  String? externalVisitorId;
  String? contactName;
  String? contactEmail;
  String? contactCompanyId;
  String? contactCompanyName;
  bool? contactOwner;
  String? contactUserRole;
  String? contactSubscriptionPlan;
  String? contactSubscriptionPeriod;
  String? contactId;
  List<String>? dynamicList;
  String? lastWebWidgetShown;
  bool? segmentCall;

  TrackingRequest({
    this.workSpaceId,
    this.companyId,
    this.cookieId,
    this.sessCookieId,
    this.firstPageQStr,
    this.firstSeen,
    this.firstPage,
    this.pagesViewed,
    this.pagesViewedLogs,
    this.firstReferringSite,
    this.firstUserAgent,
    this.firstBrowserLanguage,
    this.firstDevice,
    this.firstScreenSize,
    this.lastSeen,
    this.lastPage,
    this.lastReferringSite,
    this.lastUserAgent,
    this.lastDevice,
    this.lastScreenSize,
    this.lastBrowserLanguage,
    this.externalVisitorId,
    this.contactName,
    this.contactEmail,
    this.contactCompanyId,
    this.contactCompanyName,
    this.contactOwner,
    this.contactUserRole,
    this.contactSubscriptionPlan,
    this.contactSubscriptionPeriod,
    this.contactId,
    this.dynamicList,
    this.lastWebWidgetShown,
    this.segmentCall,
  });

  /// From JSON
  factory TrackingRequest.fromJson(Map<String, dynamic> json) {
    return TrackingRequest(
      workSpaceId: json['workSpaceId'] as String?,
      companyId: json['companyId'] as String?,
      cookieId: json['cookieId'] as String?,
      sessCookieId: json['sessCookieId'] as String?,
      firstPageQStr: json['firstPageQStr'] as String?,
      firstSeen: json['firstSeen'] as String?,
      firstPage: json['firstPage'] as String?,
      pagesViewed: (json['pagesViewed'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      pagesViewedLogs: (json['pagesViewedLogs'] as List<dynamic>?)
          ?.map((e) => PagesViewedLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstReferringSite: json['firstReferringSite'] as String?,
      firstUserAgent: json['firstUserAgent'] as String?,
      firstBrowserLanguage: json['firstBrowserLanguage'] as String?,
      firstDevice: json['firstDevice'] as String?,
      firstScreenSize: json['firstScreenSize'] as String?,
      lastSeen: json['lastSeen'] as String?,
      lastPage: json['lastPage'] as String?,
      lastReferringSite: json['lastReferringSite'] as String?,
      lastUserAgent: json['lastUserAgent'] as String?,
      lastDevice: json['lastDevice'] as String?,
      lastScreenSize: json['lastScreenSize'] as String?,
      lastBrowserLanguage: json['lastBrowserLanguage'] as String?,
      externalVisitorId: json['externalVisitorId'] as String?,
      contactName: json['contact_name'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactCompanyId: json['contact_companyid'] as String?,
      contactCompanyName: json['contact_company_name'] as String?,
      contactOwner: json['contact_owner'] as bool?,
      contactUserRole: json['contact_user_role'] as String?,
      contactSubscriptionPlan: json['contact_subscription_plan'] as String?,
      contactSubscriptionPeriod: json['contact_subscription_period'] as String?,
      contactId: json['contactId'] as String?,
      dynamicList: (json['dynamicList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lastWebWidgetShown: json['lastWebWidgetShown'] as String?,
      segmentCall: json['segmentCall'] as bool?,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'workSpaceId': workSpaceId,
      'companyId': companyId,
      'cookieId': cookieId,
      'sessCookieId': sessCookieId,
      'firstPageQStr': firstPageQStr,
      'firstSeen': firstSeen,
      'firstPage': firstPage,
      'pagesViewed': pagesViewed,
      'pagesViewedLogs': pagesViewedLogs?.map((e) => e.toJson()).toList(),
      'firstReferringSite': firstReferringSite,
      'firstUserAgent': firstUserAgent,
      'firstBrowserLanguage': firstBrowserLanguage,
      'firstDevice': firstDevice,
      'firstScreenSize': firstScreenSize,
      'lastSeen': lastSeen,
      'lastPage': lastPage,
      'lastReferringSite': lastReferringSite,
      'lastUserAgent': lastUserAgent,
      'lastDevice': lastDevice,
      'lastScreenSize': lastScreenSize,
      'lastBrowserLanguage': lastBrowserLanguage,
      'externalVisitorId': externalVisitorId,
      'contact_name': contactName,
      'contact_email': contactEmail,
      'contact_companyid': contactCompanyId,
      'contact_company_name': contactCompanyName,
      'contact_owner': contactOwner,
      'contact_user_role': contactUserRole,
      'contact_subscription_plan': contactSubscriptionPlan,
      'contact_subscription_period': contactSubscriptionPeriod,
      'contactId': contactId,
      'dynamicList': dynamicList,
      'lastWebWidgetShown': lastWebWidgetShown,
      'segmentCall': segmentCall,
    };
  }
}
