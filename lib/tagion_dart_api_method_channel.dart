import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tagion_dart_api_platform_interface.dart';

/// An implementation of [TagionDartApiPlatform] that uses method channels.
class MethodChannelTagionDartApi extends TagionDartApiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tagion_dart_api');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
