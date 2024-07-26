import 'dart:ffi';
import 'dart:io';

/// A utility class to load the library.
class LibraryUtil {
  static const String _libraryName = 'libtauonapi.so';

  const LibraryUtil._();

  static DynamicLibrary load() {
    return Platform.isAndroid ? DynamicLibrary.open(_libraryName) : DynamicLibrary.process();
  }
}
