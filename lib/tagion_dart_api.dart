
import 'tagion_dart_api_platform_interface.dart';

class TagionDartApi {
  Future<String?> getPlatformVersion() {
    return TagionDartApiPlatform.instance.getPlatformVersion();
  }
}
