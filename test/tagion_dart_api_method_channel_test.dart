import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/tagion_dart_api_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelTagionDartApi platform = MethodChannelTagionDartApi();
  const MethodChannel channel = MethodChannel('tagion_dart_api');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
