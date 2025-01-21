
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
- **Flutter:** Version 3.0.0 or higher.
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
      token: '{{SDK_TOKEN}}', // Replace with your SDK token
      zfRegion: '{{REGION}}', // Options: US, EU, IN
      context: context,
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
   
To configure the display height for the survey, pass value in `displayHeight`:
Value should be between 1 to 2. If not passed the default value is 1.6

 
 
---

## Setup
To configure and start the survey in your app:

```dart
import 'package:zonkafeedback_sdk/zonkafeedback_sdk.dart';

ZFSurvey().startSurvey();
```

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
