import 'package:zonkafeedback_sdk/src/model/widget_response/trigger.dart';

import 'devices.dart';
import 'include_segment.dart';
import 'exclude_segment.dart';

class EmbedSettings {
  String? embedType;
  String? type;
  String? buttonTextColor;
  String? buttonBgColor;
  String? buttonPosition;
  String? variant;
  String? buttonText;
  Trigger? trigger;
  Devices? devices;
  int? appearance;
  String? visibleTill;
  bool? welcomescreen;
  bool? logo;
  bool? progress;
  bool? autoclose;
  IncludeSegment? includeSegment;
  ExcludeSegment? excludeSegment;

  EmbedSettings({
    this.embedType,
    this.type,
    this.buttonTextColor,
    this.buttonBgColor,
    this.buttonPosition,
    this.variant,
    this.buttonText,
    this.trigger,
    this.devices,
    this.appearance,
    this.visibleTill,
    this.welcomescreen,
    this.logo,
    this.progress,
    this.autoclose,
    this.includeSegment,
    this.excludeSegment,
  });

  factory EmbedSettings.fromJson(Map<String, dynamic> json) {
    return EmbedSettings(
      embedType: json['embedType'],
      type: json['type'],
      buttonTextColor: json['button_text_color'],
      buttonBgColor: json['button_bg_color'],
      buttonPosition: json['button_position'],
      variant: json['variant'],
      buttonText: json['button_text'],
      trigger:
          json['trigger'] != null ? Trigger.fromJson(json['trigger']) : null,
      devices:
          json['devices'] != null ? Devices.fromJson(json['devices']) : null,
      appearance: json['appearance'],
      visibleTill: json['visibleTill'],
      welcomescreen: json['welcomescreen'],
      logo: json['logo'],
      progress: json['progress'],
      autoclose: json['autoclose'],
      includeSegment: json['includeSegment'] != null
          ? IncludeSegment.fromJson(json['includeSegment'])
          : null,
      excludeSegment: json['excludeSegment'] != null
          ? ExcludeSegment.fromJson(json['excludeSegment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'embedType': embedType,
      'type': type,
      'button_text_color': buttonTextColor,
      'button_bg_color': buttonBgColor,
      'button_position': buttonPosition,
      'variant': variant,
      'button_text': buttonText,
      'trigger': trigger?.toJson(),
      'devices': devices?.toJson(),
      'appearance': appearance,
      'visibleTill': visibleTill,
      'welcomescreen': welcomescreen,
      'logo': logo,
      'progress': progress,
      'autoclose': autoclose,
      'includeSegment': includeSegment?.toJson(),
      'excludeSegment': excludeSegment?.toJson(),
    };
  }
}
