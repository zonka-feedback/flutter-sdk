// import 'package:flutter_test/flutter_test.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockZonkafeedbackSdkPlatform with MockPlatformInterfaceMixin implements ZonkafeedbackSdkPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final ZonkafeedbackSdkPlatform initialPlatform = ZonkafeedbackSdkPlatform.instance;

//   test('$MethodChannelZonkafeedbackSdk is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelZonkafeedbackSdk>());
//   });

//   test('getPlatformVersion', () async {
//     ZonkafeedbackSdk zonkafeedbackSdkPlugin = ZonkafeedbackSdk();
//     MockZonkafeedbackSdkPlatform fakePlatform = MockZonkafeedbackSdkPlatform();
//     ZonkafeedbackSdkPlatform.instance = fakePlatform;

//     expect(await zonkafeedbackSdkPlugin.getPlatformVersion(), '42');
//   });
// }
