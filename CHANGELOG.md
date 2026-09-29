# Changelog

## 1.2.3
- Added support for the **On page delay** setting configured in the dashboard;
  the survey now waits `embedSettings.trigger.after` seconds before appearing
- A pending delay is cancelled if the app is backgrounded, so the survey no
  longer appears unprompted when the user returns
- Fixed a crash in `Trigger.fromJson` where a non-integer `after` or `scroll`
  value silently suppressed the survey for every token
- Repeated `startSurvey()` calls can no longer stack multiple surveys
- Fixed segmenting rejecting every contact when a distribution's include
  segment had `type: "all"` alongside a non-empty `list`
- Raised the minimum Flutter version to 3.7.0

## 1.2.2
- Removed deprecated `@required` annotations from `ApiResult`; use of the
  built-in `required` keyword has superseded them since Dart 2.12
- Resolves the two remaining `dart analyze` infos, restoring a full score in
  pana's static analysis section

## 1.2.1
- Fixed survey content visibly jumping when Popup and Slide-up surveys first open
- Loader now stays visible until the survey layout has settled, and fully covers the WebView while loading
- Made the `DioExceptionType` switch exhaustive so `dart analyze` reports no errors

## 1.2.0
- Added SVG close icon for Popup and Slide-up UIs
- Bundled asset at `assets/icons/close.svg` and wired loading via package assets
- Added documentation for `closeIconPosition` and rebuild note in README

## 1.1.9
- Multiple Token Add

## 1.1.8
- Multiple Token Add

## 1.1.7
- Multiple Token Add

## 1.1.6
- Multiple Token Add

## 1.1.5
- UI Updates

## 1.1.4
- UI Updates

## 1.1.3
- UI Updates

## 1.1.2
- Added support for display height

## 1.1.1
- Performance Improvements

## 1.1.0
- Added support for Survey Display type (popup & slide-up)

## 1.0.0
- Official Flutter SDK for Zonka Feedback

## 0.1.1
- Initial release.

## 0.1.0
- Initial release.



