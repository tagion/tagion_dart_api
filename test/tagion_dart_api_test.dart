import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/tagion_dart_api.dart';
import 'package:tagion_dart_api/tagion_dart_api_platform_interface.dart';
import 'package:tagion_dart_api/tagion_dart_api_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTagionDartApiPlatform
    with MockPlatformInterfaceMixin
    implements TagionDartApiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TagionDartApiPlatform initialPlatform = TagionDartApiPlatform.instance;

  test('$MethodChannelTagionDartApi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTagionDartApi>());
  });

  test('getPlatformVersion', () async {
    TagionDartApi tagionDartApiPlugin = TagionDartApi();
    MockTagionDartApiPlatform fakePlatform = MockTagionDartApiPlatform();
    TagionDartApiPlatform.instance = fakePlatform;

    expect(await tagionDartApiPlugin.getPlatformVersion(), '42');
  });
}
