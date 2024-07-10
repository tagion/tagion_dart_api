import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tagion_dart_api/pointer_util.dart';

extension PointerHelper on PointerUtil {
  // Helper method to allocate memory for the type.
  static Pointer<T> allocateType<T extends NativeType>(int size) {
    switch (T) {
      case Uint8:
        return malloc<Uint8>(size).cast<T>();
      case Int8:
        return malloc<Int8>(size).cast<T>();
      case Uint16:
        return malloc<Uint16>(size).cast<T>();
      case Int16:
        return malloc<Int16>(size).cast<T>();
      case Uint32:
        return malloc<Uint32>(size).cast<T>();
      case Int32:
        return malloc<Int32>(size).cast<T>();
      case Uint64:
        return malloc<Uint64>(size).cast<T>();
      case Int64:
        return malloc<Int64>(size).cast<T>();
      case Float:
        return malloc<Float>(size).cast<T>();
      case Double:
        return malloc<Double>(size).cast<T>();
      case IntPtr:
        return malloc<IntPtr>(size).cast<T>();
      case Char:
        return malloc<Char>(size).cast<T>();
      default:
        throw UnsupportedError('Unsupported type');
    }
  }

  // Helper method to get the size of the type.
  static int sizeOfType<T extends NativeType>() {
    switch (T) {
      case Uint8:
        return sizeOf<Uint8>();
      case Int8:
        return sizeOf<Int8>();
      case Uint16:
        return sizeOf<Uint16>();
      case Int16:
        return sizeOf<Int16>();
      case Uint32:
        return sizeOf<Uint32>();
      case Int32:
        return sizeOf<Int32>();
      case Uint64:
        return sizeOf<Uint64>();
      case Int64:
        return sizeOf<Int64>();
      case Float:
        return sizeOf<Float>();
      case Double:
        return sizeOf<Double>();
      case IntPtr:
        return sizeOf<IntPtr>();
      case Void:
        return sizeOf<Void>();
      case Char:
        return sizeOf<Char>();
      default:
        throw UnsupportedError('Unsupported type');
    }
  }
}
