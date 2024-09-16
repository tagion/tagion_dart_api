
import 'dart:convert';
import 'dart:ffi';

/// Extension method to convert a Pointer<Char> to a Dart string.
extension CharPointer on Pointer<Char> {
  String toDartString({required int length}) {
    final List<int> units = List<int>.generate(length, (int i) {
      return elementAt(i).value;
    });
    return utf8.decode(units);
  }
}