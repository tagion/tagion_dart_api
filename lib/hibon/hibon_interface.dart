import 'package:tagion_dart_api/enums/hibon_string_format.dart';

abstract class IHibon {
  /// It is necessary to call this method before calling any other method. It creates a Hibon object.
  void init();
  void addString(String key, String value);
  String getAsString([HibonAsStringFormat format]);
  void free();
}
