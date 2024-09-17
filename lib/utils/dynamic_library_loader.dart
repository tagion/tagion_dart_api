import 'dart:ffi';
import 'dart:io';

import 'package:tagion_dart_api/global.dart';

/// A utility class to load the library.
class DynamicLibraryLoader {
  const DynamicLibraryLoader._();

  static DynamicLibrary load() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('lib$libName.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('lib$libName.dll');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('lib$libName.so');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('lib$libName.dylib');
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }
}
