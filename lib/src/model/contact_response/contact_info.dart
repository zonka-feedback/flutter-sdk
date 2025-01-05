
import 'attribute.dart';

class ContactInfo {
  String? name;
  String? emailAddress;
  String? mobile;
  String? uniqueId;
  List<String>? lists;
  bool? isDeleted;
  bool? unsubscribeEmail;
  bool? unsubscribeSMS;
  dynamic lastSmsSurveySentDatetime;
  dynamic lastEmailSurveySentDatetime;
  dynamic createdBy;
  dynamic modifiedBy;
  int? totalResponses;
  dynamic lastResponseDateTime;
  bool? bounced;
  List<dynamic>? surveys;
  List<dynamic>? locations;
  List<Attribute>? attributes;
  String? source;
  int? numTasks;
  int? numPendingTasks;
  int? numNotes;
  bool? hasNote;
  dynamic thirdpartySignupDate;
  dynamic thirdpartyCreatedDate;
  dynamic thirdpartyUpdatedDate;
  dynamic firstSeen;
  dynamic lastSeen;
  dynamic firstPage;
  String? lastPage;
  dynamic lastWebWidgetShown;
  dynamic lastSurveyViewedId;
  dynamic lastSurveyViewedDate;
  int? sessionCounts;
  int? webSessionCounts;
  int? androidSessionCounts;
  int? iosSessionCounts;
  dynamic mauNextCountAfterDate;
  int? pagesViewedCount;
  String? contactSource;
  String? utmTerm;
  String? utmCampaign;
  String? utmMedium;
  String? utmSource;
  String? utmContent;
  String? firstReferringSite;
  String? lastReferringSite;
  dynamic languageCode;
  List<dynamic>? surveysVisits;
  dynamic lastSessionActiveAt;
  bool? historyImportedFromAnonymous;
  dynamic firstSeenOnIOS;
  dynamic firstSeenOnAndroid;
  dynamic lastSeenOnIOS;
  dynamic lastSeenOnAndroid;
  String? id;
  String? companyId;
  String? cookieId;
  String? createdDate;
  String? modifiedDate;
  int? preMongifiedId;

  ContactInfo({
    this.name,
    this.emailAddress,
    this.mobile,
    this.uniqueId,
    this.lists,
    this.isDeleted,
    this.unsubscribeEmail,
    this.unsubscribeSMS,
    this.lastSmsSurveySentDatetime,
    this.lastEmailSurveySentDatetime,
    this.createdBy,
    this.modifiedBy,
    this.totalResponses,
    this.lastResponseDateTime,
    this.bounced,
    this.surveys,
    this.locations,
    this.attributes,  
    this.source,
    this.numTasks,
    this.numPendingTasks,
    this.numNotes,
    this.hasNote,
    this.thirdpartySignupDate,
    this.thirdpartyCreatedDate,
    this.thirdpartyUpdatedDate,
    this.firstSeen,
    this.lastSeen,
    this.firstPage,
    this.lastPage,
    this.lastWebWidgetShown,
    this.lastSurveyViewedId,
    this.lastSurveyViewedDate,
    this.sessionCounts,
    this.webSessionCounts,
    this.androidSessionCounts,
    this.iosSessionCounts,
    this.mauNextCountAfterDate,
    this.pagesViewedCount,
    this.contactSource,
    this.utmTerm,
    this.utmCampaign,
    this.utmMedium,
    this.utmSource,
    this.utmContent,
    this.firstReferringSite,
    this.lastReferringSite,
    this.languageCode,
    this.surveysVisits,
    this.lastSessionActiveAt,
    this.historyImportedFromAnonymous,
    this.firstSeenOnIOS,
    this.firstSeenOnAndroid,
    this.lastSeenOnIOS,
    this.lastSeenOnAndroid,
    this.id,
    this.companyId,
    this.cookieId,
    this.createdDate,
    this.modifiedDate,
    this.preMongifiedId,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      name: json['name'] as String?,
      emailAddress: json['emailAddress'] as String?,
      mobile: json['mobile'] as String?,
      uniqueId: json['uniqueId'] as String?,
      lists: (json['lists'] as List<dynamic>?)?.cast<String>(),
      isDeleted: json['isDeleted'] as bool?,
      unsubscribeEmail: json['unsubscribeEmail'] as bool?,
      unsubscribeSMS: json['unsubscribeSMS'] as bool?,
      lastSmsSurveySentDatetime: json['lastSmsSurveySentDatetime'],
      lastEmailSurveySentDatetime: json['lastEmailSurveySentDatetime'],
      createdBy: json['createdBy'],
      modifiedBy: json['modifiedBy'],
      totalResponses: json['totalResponses'] as int?,
      lastResponseDateTime: json['lastResponseDateTime'],
      bounced: json['bounced'] as bool?,
      surveys: json['surveys'] as List<dynamic>?,
      locations: json['locations'] as List<dynamic>?,
      attributes: (json['attributes'] as List<dynamic>?)?.map((e) => Attribute.fromJson(e as Map<String, dynamic>)).toList(),
      source: json['source'] as String?,
      numTasks: json['numTasks'] as int?,
      numPendingTasks: json['numPendingTasks'] as int?,
      numNotes: json['numNotes'] as int?,
      hasNote: json['hasNote'] as bool?,
      thirdpartySignupDate: json['thirdpartySingupDate'],
      thirdpartyCreatedDate: json['thirdpartyCreatedDate'],
      thirdpartyUpdatedDate: json['thirdpartyUpdatedDate'],
      firstSeen: json['firstSeen'],
      lastSeen: json['lastSeen'],
      firstPage: json['firstPage'],
      lastPage: json['lastPage'] as String?,
      lastWebWidgetShown: json['lastWebWidgetShown'],
      lastSurveyViewedId: json['lastSurveyViewedId'],
      lastSurveyViewedDate: json['lastSurveyViewedDate'],
      sessionCounts: json['sessionCounts'] as int?,
      webSessionCounts: json['webSessionCounts'] as int?,
      androidSessionCounts: json['androidSessionCounts'] as int?,
      iosSessionCounts: json['iosSessionCounts'] as int?,
      mauNextCountAfterDate: json['mauNextCountAfterDate'],
      pagesViewedCount: json['pagesViewedCount'] as int?,
      contactSource: json['contactSource'] as String?,
      utmTerm: json['utm_term'] as String?,
      utmCampaign: json['utm_campaign'] as String?,
      utmMedium: json['utm_medium'] as String?,
      utmSource: json['utm_source'] as String?,
      utmContent: json['utm_content'] as String?,
      firstReferringSite: json['firstReferringSite'] as String?,
      lastReferringSite: json['lastReferringSite'] as String?,
      languageCode: json['languageCode'],
      surveysVisits: json['surveysVisits'] as List<dynamic>?,
      lastSessionActiveAt: json['lastSessionActiveAt'],
      historyImportedFromAnonymous: json['historyImportedFromAnonymous'] as bool?,
      firstSeenOnIOS: json['firstSeenOnIOS'],
      firstSeenOnAndroid: json['firstSeenOnAndroid'],
      lastSeenOnIOS: json['lastSeenOnIOS'],
      lastSeenOnAndroid: json['lastSeenOnAndroid'],
      id: json['_id'] as String?,
      companyId: json['companyId'] as String?,
      cookieId: json['cookieId'] as String?,
      createdDate: json['createdDate'] as String?,
      modifiedDate: json['modifiedDate'] as String?,
      preMongifiedId: json['pre_mongified_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'emailAddress': emailAddress,
      'mobile': mobile,
      'uniqueId': uniqueId,
      'lists': lists,
      'isDeleted': isDeleted,
      'unsubscribeEmail': unsubscribeEmail,
      'unsubscribeSMS': unsubscribeSMS,
      'lastSmsSurveySentDatetime': lastSmsSurveySentDatetime,
      'lastEmailSurveySentDatetime': lastEmailSurveySentDatetime,
      'createdBy': createdBy,
      'modifiedBy': modifiedBy,
      'totalResponses': totalResponses,
      'lastResponseDateTime': lastResponseDateTime,
      'bounced': bounced,
      'surveys': surveys,
      'locations': locations,
      'attributes': attributes?.map((e) => e.toJson()).toList(),
      'source': source,
      'numTasks': numTasks,
      'numPendingTasks': numPendingTasks,
      'numNotes': numNotes,
      'hasNote': hasNote,
      'thirdpartySingupDate': thirdpartySignupDate,
      'thirdpartyCreatedDate': thirdpartyCreatedDate,
      'thirdpartyUpdatedDate': thirdpartyUpdatedDate,
      'firstSeen': firstSeen,
      'lastSeen': lastSeen,
      'firstPage': firstPage,
      'lastPage': lastPage,
      'lastWebWidgetShown': lastWebWidgetShown,
      'lastSurveyViewedId': lastSurveyViewedId,
      'lastSurveyViewedDate': lastSurveyViewedDate,
      'sessionCounts': sessionCounts,
      'webSessionCounts': webSessionCounts,
      'androidSessionCounts': androidSessionCounts,
      'iosSessionCounts': iosSessionCounts,
      'mauNextCountAfterDate': mauNextCountAfterDate,
      'pagesViewedCount': pagesViewedCount,
      'contactSource': contactSource,
      'utm_term': utmTerm,
      'utm_campaign': utmCampaign,
      'utm_medium': utmMedium,
      'utm_source': utmSource,
      'utm_content': utmContent,
      'firstReferringSite': firstReferringSite,
      'lastReferringSite': lastReferringSite,
      'languageCode': languageCode,
      'surveysVisits': surveysVisits,
      'lastSessionActiveAt': lastSessionActiveAt,
      'historyImportedFromAnonymous': historyImportedFromAnonymous,
      'firstSeenOnIOS': firstSeenOnIOS,
      'firstSeenOnAndroid': firstSeenOnAndroid,
      'lastSeenOnIOS': lastSeenOnIOS,
      'lastSeenOnAndroid': lastSeenOnAndroid,
      '_id': id,
      'companyId': companyId,
      'cookieId': cookieId,
      'createdDate': createdDate,
      'modifiedDate': modifiedDate,
      'pre_mongified_id': preMongifiedId,
    };
  }
}

