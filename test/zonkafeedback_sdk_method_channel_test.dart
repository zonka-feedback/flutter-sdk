// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();

//   MethodChannelZonkafeedbackSdk platform = MethodChannelZonkafeedbackSdk();
//   const MethodChannel channel = MethodChannel('zonkafeedback_sdk');

//   setUp(() {
//     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
//       channel,
//       (MethodCall methodCall) async {
//         return '42';
//       },
//     );
//   });

//   tearDown(() {
//     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
//   });

//   test('getPlatformVersion', () async {
//     expect(await platform.getPlatformVersion(), '42');
//   });
// }
