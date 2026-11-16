
# Zonka Feedback Flutter SDK

## Pre-Requisites
The Zonka Feedback Flutter SDK requires:
- **Zonka Feedback Account:** An active Zonka Feedback account.
- **SDK Token:** Obtain this token for the survey you want to implement:
    1. Create a [Zonka Feedback account](https://www.zonkafeedback.com/free-trial-signup?utm_campaign=Free%20Trial%20Buttons&utm_source=flutter_sdk).
    2. Create a new survey with the desired questions.
    3. Navigate to the **Distribute** menu → **In-App** tab.
    4. Enable the toggle to view your SDK token.

Follow the steps below to integrate the SDK into your app.

> Learn more about creating surveys on [Zonka Feedback](https://help.zonkafeedback.com/en/articles/6389318-getting-started-with-zonka-feedback).

---

## Minimum Requirements
- **Flutter:** Version 3.7.0 or higher.
- **Android:**
    - CompileSdk version: 34 or higher.
    - Android Gradle Plugin: 8.1.0 or higher.
- **iOS:** iOS 14 or higher.

---

## Installation
Add the Zonka Feedback SDK as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  zonkafeedback_sdk: <latest_version>
```

---


## Configuration
**Configuration for iOS** : Add the following snippet to your **Info.plist** file.

```yaml
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
  </dict>
```


## Initialization
Initialize the SDK in your app's main file (e.g., `lib/main.dart`):

```dart
import 'package:zonkafeedback_sdk/zonkafeedback_sdk.dart';

class _ZonkaFeedBackSurveyState extends State<ZonkaFeedBackSurvey> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ZFSurvey().init(
      token: ['{{SDK_TOKEN}}'], // Replace with your SDK token
      zfRegion: '{{REGION}}', // Options: US, EU, IN
      context: context,
      closeIconType: 'icon2',
      minimumHeight: 410,
      closeIconPosition: "right",
      expandedHeight: 580,
      autoClose:false
    );
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ZFSurvey().sendAppLifecycleState(state);
    super.didChangeAppLifecycleState(state);
  }
}
```
# Survey Display Configuration options

To configure the display type for the survey, use one of the following options with `displayType`:

1. **popup**  
   - Shows the survey as a popup in the center of the screen.

2. **slide-up**  
   - Displays the survey as a slide-up bottom sheet.
   

# Survey Height Configuration
 

1. **minimum-height**  
   - You can give minimum height to survey ui slide-up and popup using key `minimumHeight`.

2. **expanded-height**  
   - You can give maximum height to survey ui slide-up and popup using key `expandedHeight`.


# Auto Close 
 
To configure the auto close icon for the survey, use one of the following options with `autoClose`:

1. **autoClose**  
   - You can set autoClose `true` which enable survey to close automatically..

2. **autoClose**  
   - You can set autoClose `false` which disable survey to close automatically.

  
 # Close Icon Position
 
To configure the close icon for the survey, use one of the following options with `closeIconPosition`:

1. **left**  
   - You can give position to close icon to left by using value `left`.

2. **right**  
   -  You can give position to close icon to right by using value `right`.
   

# Close Icon Type

Two built-in close icon styles are bundled with the SDK:

- **icon1**  
  - Minimal “X” without the circular background

- **icon2**  
  - Circle background with an “X” (the current default across Popup and Slide-up)


Note: The current release uses **icon1** by default. The ability to switch types will be introduced in an upcoming update.

 
---

## Setup
To configure and start the survey in your app:

```dart
import 'package:zonkafeedback_sdk/zonkafeedback_sdk.dart';

ZFSurvey().startSurvey();
```

---

## Segment Delay

A survey targeted at a segment can wait until the contact has been in that
segment for a number of seconds. This is configured per distribution in the
Zonka Feedback dashboard under **In-App SDK → Configuration → On page delay**,
and is delivered to the SDK as `embedSettings.trigger.after`. There is no code
parameter — the SDK reads whatever the dashboard is set to.

The delay is counted from the contact's membership of the segment, not from
when `startSurvey()` is called. `contacts/tracking` returns when the contact's
membership of each list last changed:

```json
"lists": ["6afaa179b78b00e6a253da0f"],
"listMemberships": {
  "6afaa179b78b00e6a253da0f": {
    "createdDate": "2026-11-16T06:32:05.226Z",
    "modifiedDate": "2026-11-16T06:32:05.226Z"
  }
}
```

An included segment only counts once `modifiedDate + delay` has passed. If
`startSurvey()` runs before then, the survey is not shown yet; instead the SDK
waits until that time and shows it automatically if the user is still in the
app. For example, with a 30 minute delay, a contact who joined the segment 10
minutes ago sees the survey 20 minutes later without another `startSurvey()`
call. If the contact is in several included segments, the earliest one decides.

The wait only runs while the app is in the foreground. If the time passes while
the app is in the background, the survey is shown as soon as the user returns.
Each `startSurvey()` call re-fetches the contact and recalculates the time, and
`clear()` cancels it. For this to work the host app must forward lifecycle
events:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  ZFSurvey().sendAppLifecycleState(state);
  super.didChangeAppLifecycleState(state);
}
```

- Excluded segments apply immediately; the delay does not hold them back.
- A distribution with no segment restriction (or include type `all`) shows the
  survey straight away.
- A list with no entry in `listMemberships` is not delayed.
- A distribution with no delay shows the survey immediately, as before.

---

## Optional Parameters

### 1. Send Device Details
Send device details (OS, version, IP address, device type) with responses. Enabled by default.

```dart
ZFSurvey().sendDeviceDetails(true);
```

---

### 2. Send Custom Attributes
Add additional data (e.g., screen name, order ID) to responses.

```dart
Map<String, String> properties = {
  'property1': 'value1',
  'property2': 'value2',
};

ZFSurvey().sendCustomAttributes(properties);
```

---

## Identifying Logged-In Visitors
Identify users by passing their details like name, email, mobile, or unique ID:

```dart
Map<String, dynamic> properties = {
  'contact_name': 'Robin James',
  'contact_email': 'robin@example.com',
  'contact_uniqueId': '1XJ2',
  'contact_mobile': '+14234XXXX',
};

ZFSurvey().userInfo(properties);
```

---

## Reset Visitor Attributes
Clear visitor data on logout:

```dart
ZFSurvey().clear();
```
---



