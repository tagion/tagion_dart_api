import 'dart:ffi';
import 'dart:io';

/// A utility class to load the library.
class FFILibraryUtil {
  static const String _libraryName = 'libtauonapi.so';

  const FFILibraryUtil._();

  static DynamicLibrary load() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open(_libraryName);
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    } else if (Platform.isWindows) {
      return DynamicLibrary.open(_libraryName);
    } else if (Platform.isLinux) {
      return DynamicLibrary.open(_libraryName);
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open(_libraryName);
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }
}
