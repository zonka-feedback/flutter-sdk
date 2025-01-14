import 'package:flutter/material.dart';
import 'package:zonkafeedback_sdk/zonkafeedback_sdk.dart';

import 'attribute_form.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ZonkaFeedBackSurvey(),
    );
  }
}

class ZonkaFeedBackSurvey extends StatefulWidget {
  const ZonkaFeedBackSurvey({super.key});

  @override
  State<ZonkaFeedBackSurvey> createState() => _ZonkaFeedBackSurveyState();
}

class _ZonkaFeedBackSurveyState extends State<ZonkaFeedBackSurvey>
    with WidgetsBindingObserver {
  @override
  void initState() {
    ZFSurvey().init(token: 'rI4k8H', zfRegion: 'US', context: context, displayType: 'popup');
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ZFSurvey().sendAppLifecycleState(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Map<String, dynamic> properties = {
                  'contact_name': 'Robin James',
                  'contact_email': 'robin@example.com',
                  'contact_uniqueId': '1XJ2',
                };

                ZFSurvey()
                    .sendDeviceDetails(true)
                    .sendCustomAttributes(properties)
                    .startSurvey();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'START SURVEY',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                ZFSurvey().clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'CLEAR VALUES',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
