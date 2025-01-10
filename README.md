
# Zonka Feedback Flutter SDK

## Pre-Requisites
The Zonka Feedback Flutter SDK requires:
- **Zonka Feedback Account:** An active Zonka Feedback account.
- **SDK Token:** Obtain this token for the survey you want to implement:
    1. Create a Zonka Feedback account.
    2. Create a new survey with the desired questions.
    3. Navigate to the **Distribute** menu → **In-App** tab.
    4. Enable the toggle to view your SDK token.

Follow the steps below to integrate the SDK into your app.

> Learn more about creating surveys on [Zonka Feedback](https://www.zonkafeedback.com/).

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



