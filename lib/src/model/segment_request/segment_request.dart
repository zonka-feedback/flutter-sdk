

class SegmentRequest {
  String? workSpaceId;
  String? companyId;
  String? cookieId;
  String? sessCookieId;
  String? firstPageQStr;
  String? firstSeen;
  String? firstPage;
  List<String>? pagesViewed;
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
  String? contactCompanyid;
  String? contactCompanyName;
  bool? contactOwner;
  String? contactUserRole;
  String? contactSubscriptionPlan;
  String? contactSubscriptionPeriod;
  String? contactId;
  List<String>? dynamicList;
  List<String>? includedSegment;
  List<String>? excludedSegment;
  String? lastWebWidgetShown;
  bool? segmentCall;

  SegmentRequest({
    this.workSpaceId,
    this.companyId,
    this.cookieId,
    this.sessCookieId,
    this.firstPageQStr,
    this.firstSeen,
    this.firstPage,
    this.pagesViewed,
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
    this.contactCompanyid,
    this.contactCompanyName,
    this.contactOwner,
    this.contactUserRole,
    this.contactSubscriptionPlan,
    this.contactSubscriptionPeriod,
    this.contactId,
    this.dynamicList,
    this.includedSegment,
    this.excludedSegment,
    this.lastWebWidgetShown,
    this.segmentCall,
  });

  // fromJson method to create an instance of SegmentRequest from JSON data
  factory SegmentRequest.fromJson(Map<String, dynamic> json) {
    return SegmentRequest(
      workSpaceId: json['workSpaceId'],
      companyId: json['companyId'],
      cookieId: json['cookieId'],
      sessCookieId: json['sessCookieId'],
      firstPageQStr: json['firstPageQStr'],
      firstSeen: json['firstSeen'],
      firstPage: json['firstPage'],
      pagesViewed: json['pagesViewed'] != null ? List<String>.from(json['pagesViewed']) : null,
      firstReferringSite: json['firstReferringSite'],
      firstUserAgent: json['firstUserAgent'],
      firstBrowserLanguage: json['firstBrowserLanguage'],
      firstDevice: json['firstDevice'],
      firstScreenSize: json['firstScreenSize'],
      lastSeen: json['lastSeen'],
      lastPage: json['lastPage'],
      lastReferringSite: json['lastReferringSite'],
      lastUserAgent: json['lastUserAgent'],
      lastDevice: json['lastDevice'],
      lastScreenSize: json['lastScreenSize'],
      lastBrowserLanguage: json['lastBrowserLanguage'],
      externalVisitorId: json['externalVisitorId'],
      contactName: json['contact_name'],
      contactEmail: json['contact_email'],
      contactCompanyid: json['contact_companyid'],
      contactCompanyName: json['contact_company_name'],
      contactOwner: json['contact_owner'],
      contactUserRole: json['contact_user_role'],
      contactSubscriptionPlan: json['contact_subscription_plan'],
      contactSubscriptionPeriod: json['contact_subscription_period'],
      contactId: json['contactId'],
      dynamicList: json['dynamicList'] != null ? List<String>.from(json['dynamicList']) : null,
      includedSegment: json['includedSegment'] != null ? List<String>.from(json['includedSegment']) : null,
      excludedSegment: json['excludedSegment'] != null ? List<String>.from(json['excludedSegment']) : null,
      lastWebWidgetShown: json['lastWebWidgetShown'],
      segmentCall: json['segmentCall'],
    );
  }

  // toJson method to convert a SegmentRequest instance to JSON
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
      'contact_companyid': contactCompanyid,
      'contact_company_name': contactCompanyName,
      'contact_owner': contactOwner,
      'contact_user_role': contactUserRole,
      'contact_subscription_plan': contactSubscriptionPlan,
      'contact_subscription_period': contactSubscriptionPeriod,
      'contactId': contactId,
      'dynamicList': dynamicList,
      'includedSegment': includedSegment,
      'excludedSegment': excludedSegment,
      'lastWebWidgetShown': lastWebWidgetShown,
      'segmentCall': segmentCall,
    };
  }
}
