
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



