class Evd {
  final String firstSeen;
  final String lastSeen;
  final dynamic firstPage;
  final String lastPage;
  final dynamic lastWebWidgetShown;
  final dynamic lastSurveyViewedId;
  final dynamic lastSurveyViewedDate;
  final List<dynamic> surveysVisits;
  final int sessionCounts;
  final int webSessionCounts;
  final int androidSessionCounts;
  final int iosSessionCounts;
  final dynamic mauNextCountAfterDate;
  final int pagesViewedCount;
  final int totalResponses;
  final dynamic lastResponseDateTime;
  final String source;
  final String utmTerm;
  final String utmCampaign;
  final String utmMedium;
  final String utmSource;
  final String utmContent;
  final String firstReferringSite;
  final String lastReferringSite;
  final List<String> lists;
  final bool isDeleted;
  final int totalUncountedSession;
  final dynamic lastSessionActiveAt;
  final dynamic firstSeenOnIOS;
  final dynamic firstSeenOnAndroid;
  final dynamic lastSeenOnIOS;
  final dynamic lastSeenOnAndroid;
  final String id;
  final String companyId;
  final String cookieId;
  final String createdAt;
  final String updatedAt;

  Evd({
    required this.firstSeen,
    required this.lastSeen,
    required this.firstPage,
    required this.lastPage,
    required this.lastWebWidgetShown,
    required this.lastSurveyViewedId,
    required this.lastSurveyViewedDate,
    required this.surveysVisits,
    required this.sessionCounts,
    required this.webSessionCounts,
    required this.androidSessionCounts,
    required this.iosSessionCounts,
    required this.mauNextCountAfterDate,
    required this.pagesViewedCount,
    required this.totalResponses,
    required this.lastResponseDateTime,
    required this.source,
    required this.utmTerm,
    required this.utmCampaign,
    required this.utmMedium,
    required this.utmSource,
    required this.utmContent,
    required this.firstReferringSite,
    required this.lastReferringSite,
    required this.lists,
    required this.isDeleted,
    required this.totalUncountedSession,
    required this.lastSessionActiveAt,
    required this.firstSeenOnIOS,
    required this.firstSeenOnAndroid,
    required this.lastSeenOnIOS,
    required this.lastSeenOnAndroid,
    required this.id,
    required this.companyId,
    required this.cookieId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Manual fromJson method
  factory Evd.fromJson(Map<String, dynamic> json) {
    return Evd(
      firstSeen: json['firstSeen'],
      lastSeen: json['lastSeen'],
      firstPage: json['firstPage'],
      lastPage: json['lastPage'],
      lastWebWidgetShown: json['lastWebWidgetShown'],
      lastSurveyViewedId: json['lastSurveyViewedId'],
      lastSurveyViewedDate: json['lastSurveyViewedDate'],
      surveysVisits: List<dynamic>.from(json['surveysVisits'] ?? []),
      sessionCounts: json['sessionCounts'],
      webSessionCounts: json['webSessionCounts'],
      androidSessionCounts: json['androidSessionCounts'],
      iosSessionCounts: json['iosSessionCounts'],
      mauNextCountAfterDate: json['mauNextCountAfterDate'],
      pagesViewedCount: json['pagesViewedCount'],
      totalResponses: json['totalResponses'],
      lastResponseDateTime: json['lastResponseDateTime'],
      source: json['source'],
      utmTerm: json['utm_term'],
      utmCampaign: json['utm_campaign'],
      utmMedium: json['utm_medium'],
      utmSource: json['utm_source'],
      utmContent: json['utm_content'],
      firstReferringSite: json['firstReferringSite'],
      lastReferringSite: json['lastReferringSite'],
      lists: List<String>.from(json['lists'] ?? []),
      isDeleted: json['isDeleted'],
      totalUncountedSession: json['totalUncountedSession'],
      lastSessionActiveAt: json['lastSessionActiveAt'],
      firstSeenOnIOS: json['firstSeenOnIOS'],
      firstSeenOnAndroid: json['firstSeenOnAndroid'],
      lastSeenOnIOS: json['lastSeenOnIOS'],
      lastSeenOnAndroid: json['lastSeenOnAndroid'],
      id: json['_id'],
      companyId: json['companyId'],
      cookieId: json['cookieId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  // Manual toJson method
  Map<String, dynamic> toJson() {
    return {
      'firstSeen': firstSeen,
      'lastSeen': lastSeen,
      'firstPage': firstPage,
      'lastPage': lastPage,
      'lastWebWidgetShown': lastWebWidgetShown,
      'lastSurveyViewedId': lastSurveyViewedId,
      'lastSurveyViewedDate': lastSurveyViewedDate,
      'surveysVisits': surveysVisits,
      'sessionCounts': sessionCounts,
      'webSessionCounts': webSessionCounts,
      'androidSessionCounts': androidSessionCounts,
      'iosSessionCounts': iosSessionCounts,
      'mauNextCountAfterDate': mauNextCountAfterDate,
      'pagesViewedCount': pagesViewedCount,
      'totalResponses': totalResponses,
      'lastResponseDateTime': lastResponseDateTime,
      'source': source,
      'utm_term': utmTerm,
      'utm_campaign': utmCampaign,
      'utm_medium': utmMedium,
      'utm_source': utmSource,
      'utm_content': utmContent,
      'firstReferringSite': firstReferringSite,
      'lastReferringSite': lastReferringSite,
      'lists': lists,
      'isDeleted': isDeleted,
      'totalUncountedSession': totalUncountedSession,
      'lastSessionActiveAt': lastSessionActiveAt,
      'firstSeenOnIOS': firstSeenOnIOS,
      'firstSeenOnAndroid': firstSeenOnAndroid,
      'lastSeenOnIOS': lastSeenOnIOS,
      'lastSeenOnAndroid': lastSeenOnAndroid,
      '_id': id,
      'companyId': companyId,
      'cookieId': cookieId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
