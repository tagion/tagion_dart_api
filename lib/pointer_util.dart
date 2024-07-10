import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:tagion_dart_api/pointer_type_util.dart';

class PointerUtil {

  PointerUtil._();

  /// Method to allocate and initialize memory.
  static Pointer<T> allocate<T extends NativeType>(int size) {
    return PointerTypeUtil.allocateType<T>(size);
  }

  /// Method to zero out the memory pointed to by the pointer.
  static void zeroOutPointer<T extends NativeType>(Pointer<T> pointer, int size) {
    final Pointer<Uint8> bytePointer = pointer.cast<Uint8>();
    final typeSize = PointerTypeUtil.sizeOfType<T>();
    for (var i = 0; i < size * typeSize; i++) {
      bytePointer[i] = 0;
    }
  }

  /// Method to free the memory.
  static void free<T extends NativeType>(Pointer<T> pointer) {
    malloc.free(pointer);
  }

  /// Method to zero out and free the memory.
  static void zeroOutAndFree<T extends NativeType>(Pointer<T> pointer, int size) {
    zeroOutPointer(pointer, size);
    free(pointer);
  }
}
