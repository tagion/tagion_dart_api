import 'dart:ffi';
import 'dart:io';

import 'package:tagion_dart_api/global.dart';

/// A utility class to load the dynamic library.
class DynamicLibraryLoader {
  DynamicLibraryLoader._();

  static final DynamicLibraryLoader _instance = DynamicLibraryLoader._();

  factory DynamicLibraryLoader() {
    return _instance;
  }

  /// Private static variable to hold the loaded DynamicLibrary instance
  static DynamicLibrary? _library;

  /// Method to load the dynamic library once and return the same instance afterwards
  static DynamicLibrary load() {
    if (_library != null) {
      return _library!;
    }

    /// Load the library based on the platform and cache it
    if (Platform.isAndroid) {
      _library = DynamicLibrary.open('lib$libName.so');
    } else if (Platform.isIOS) {
      _library = DynamicLibrary.process();
    } else if (Platform.isWindows) {
      _library = DynamicLibrary.open('lib$libName.dll');
    } else if (Platform.isLinux) {
      _library = DynamicLibrary.open('lib$libName.so');
    } else if (Platform.isMacOS) {
      _library = DynamicLibrary.open('lib$libName.dylib');
    } else {
      throw UnsupportedError('Platform not supported');
    }

    return _library!;
  }
}
