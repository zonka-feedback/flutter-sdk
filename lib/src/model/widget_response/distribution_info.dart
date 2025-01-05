import 'embed_settings.dart';

class DistributionInfo {
  final String? type;
  final bool? isDefault;
  final bool? isDeleted;
  final bool? isActive;
  final bool? isWidgetActive;
  final bool? allowMultipleResponsesFromSameDevice;
  final bool? isWorkspaceBasedWidget;
  final String? smsMessage;
  final String? emailMessage;
  final String? emailSubject;
  final String? emailBody;
  final String? emailLogo;
  final String? emailHeading;
  final String? emailHeadingColor;
  final String? emailButtonText;
  final String? emailButtonColor;
  final String? emailButtonTextColor;
  final String? emailSignature;
  final bool? embedField;
  final bool? embedFieldButtonGradient;
  final bool? displayEmailSmsTracking;
  final dynamic endDate; // Could be DateTime or other
  final dynamic customerEndDate; // Could be DateTime or other
  final dynamic startDate; // Could be DateTime or other
  final dynamic customerStartDate; // Could be DateTime or other
  final String? createdBy;
  final String? modifiedBy;
  final String? id;
  final int? preMongifiedId;
  final String? name;
  final String? uniqueRefCode;
  final String? surveyId;
  final String? companyId;
  final String? createdDate; // Could be DateTime for better handling
  final String? modifiedDate; // Could be DateTime for better handling
  final EmbedSettings? embedSettings;

  DistributionInfo({
    this.type,
    this.isDefault,
    this.isDeleted,
    this.isActive,
    this.isWidgetActive,
    this.allowMultipleResponsesFromSameDevice,
    this.isWorkspaceBasedWidget,
    this.smsMessage,
    this.emailMessage,
    this.emailSubject,
    this.emailBody,
    this.emailLogo,
    this.emailHeading,
    this.emailHeadingColor,
    this.emailButtonText,
    this.emailButtonColor,
    this.emailButtonTextColor,
    this.emailSignature,
    this.embedField,
    this.embedFieldButtonGradient,
    this.displayEmailSmsTracking,
    this.endDate,
    this.customerEndDate,
    this.startDate,
    this.customerStartDate,
    this.createdBy,
    this.modifiedBy,
    this.id,
    this.preMongifiedId,
    this.name,
    this.uniqueRefCode,
    this.surveyId,
    this.companyId,
    this.createdDate,
    this.modifiedDate,
    this.embedSettings,
  });

  factory DistributionInfo.fromJson(Map<String, dynamic> json) {
    return DistributionInfo(
      type: json['type'] as String?,
      isDefault: json['isDefault'] as bool?,
      isDeleted: json['isDeleted'] as bool?,
      isActive: json['isActive'] as bool?,
      isWidgetActive: json['isWidgetActive'] as bool?,
      allowMultipleResponsesFromSameDevice: json['allowMultipleResponsesFromSameDevice'] as bool?,
      isWorkspaceBasedWidget: json['isWorkspaceBasedWidget'] as bool?,
      smsMessage: json['smsMessage'] as String?,
      emailMessage: json['emailMessage'] as String?,
      emailSubject: json['emailSubject'] as String?,
      emailBody: json['emailBody'] as String?,
      emailLogo: json['emailLogo'] as String?,
      emailHeading: json['emailHeading'] as String?,
      emailHeadingColor: json['emailHeadingColor'] as String?,
      emailButtonText: json['emailButtonText'] as String?,
      emailButtonColor: json['emailButtonColor'] as String?,
      emailButtonTextColor: json['emailButtonTextColor'] as String?,
      emailSignature: json['emailSignature'] as String?,
      embedField: json['embedField'] as bool?,
      embedFieldButtonGradient: json['embedFieldButtonGradient'] as bool?,
      displayEmailSmsTracking: json['displayEmailSmsTracking'] as bool?,
      endDate: json['endDate'], // Parsing depends on format
      customerEndDate: json['customerEndDate'], // Parsing depends on format
      startDate: json['startDate'], // Parsing depends on format
      customerStartDate: json['customerStartDate'], // Parsing depends on format
      createdBy: json['createdBy'] as String?,
      modifiedBy: json['modifiedBy'] as String?,
      id: json['_id'] as String?,
      preMongifiedId: json['pre_mongified_id'] as int?,
      name: json['name'] as String?,
      uniqueRefCode: json['uniqueRefCode'] as String?,
      surveyId: json['surveyId'] as String?,
      companyId: json['companyId'] as String?,
      createdDate: json['createdDate'] as String?,
      modifiedDate: json['modifiedDate'] as String?,
      embedSettings: json['embedSettings'] != null
          ? EmbedSettings.fromJson(json['embedSettings'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'isDefault': isDefault,
      'isDeleted': isDeleted,
      'isActive': isActive,
      'isWidgetActive': isWidgetActive,
      'allowMultipleResponsesFromSameDevice': allowMultipleResponsesFromSameDevice,
      'isWorkspaceBasedWidget': isWorkspaceBasedWidget,
      'smsMessage': smsMessage,
      'emailMessage': emailMessage,
      'emailSubject': emailSubject,
      'emailBody': emailBody,
      'emailLogo': emailLogo,
      'emailHeading': emailHeading,
      'emailHeadingColor': emailHeadingColor,
      'emailButtonText': emailButtonText,
      'emailButtonColor': emailButtonColor,
      'emailButtonTextColor': emailButtonTextColor,
      'emailSignature': emailSignature,
      'embedField': embedField,
      'embedFieldButtonGradient': embedFieldButtonGradient,
      'displayEmailSmsTracking': displayEmailSmsTracking,
      'endDate': endDate,
      'customerEndDate': customerEndDate,
      'startDate': startDate,
      'customerStartDate': customerStartDate,
      'createdBy': createdBy,
      'modifiedBy': modifiedBy,
      '_id': id,
      'pre_mongified_id': preMongifiedId,
      'name': name,
      'uniqueRefCode': uniqueRefCode,
      'surveyId': surveyId,
      'companyId': companyId,
      'createdDate': createdDate,
      'modifiedDate': modifiedDate,
      'embedSettings': embedSettings?.toJson(),
    };
  }
}
