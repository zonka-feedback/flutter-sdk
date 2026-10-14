# Changelog

## 1.3.1
- All tokens are now validated with one `distribution/validateCodes` request
  instead of one `validateCode/returnResponse` request per token
- If that request fails, no survey is shown for that run; the old per-token
  endpoint is no longer used as a fallback
- `checkValidation()` and resuming a delayed survey use `validateCodes` too

## 1.3.0
- The on-page delay is now a saved deadline rather than an in-memory timer.
  Backgrounding the app, locking the phone, or the app being killed no longer
  drops the survey; it is shown once the delay has passed, as soon as the app
  is in the foreground again
- The widget and segment checks run again just before a delayed survey is shown
- Added an optional `navigatorKey` to `init` so a delayed survey can be shown
  after the screen that called `init` has closed
- `startSurvey()` calls while a survey is waiting no longer restart its delay
- A survey that was waiting when the app was killed is shown after `init()`
  on the next launch
- Lifecycle events and `startSurvey()` calls made before `init()` are ignored
  instead of throwing
- `contacts/tracking` is called at most once per `startSurvey()` run

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



