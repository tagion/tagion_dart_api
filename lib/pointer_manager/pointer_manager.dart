import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';

import 'pointer_manager_interface.dart';

/// Object class providing methods to allocate, zero out, and free memory.
class PointerManager implements IPointerManager {
  const PointerManager();

  @override
  Pointer<T> allocate<T extends NativeType>([int size = 0, Allocator allocator = malloc]) {
    switch (T) {
      case Uint8:
        return allocator<Uint8>(size).cast<T>();
      case Int8:
        return allocator<Int8>(size).cast<T>();
      case Uint16:
        return allocator<Uint16>(size).cast<T>();
      case Int16:
        return allocator<Int16>(size).cast<T>();
      case Uint32:
        return allocator<Uint32>(size).cast<T>();
      case Int32:
        return allocator<Int32>(size).cast<T>();
      case Uint64:
        return allocator<Uint64>(size).cast<T>();
      case Int64:
        return allocator<Int64>(size).cast<T>();
      case Float:
        return allocator<Float>(size).cast<T>();
      case Double:
        return allocator<Double>(size).cast<T>();
      case IntPtr:
        return allocator<IntPtr>(size).cast<T>();
      case Char:
        return allocator<Char>(size).cast<T>();
      case const (Pointer<Char>):
        return allocator<Pointer>().cast<T>();
      case HiBONT:
        return allocator<HiBONT>().cast<T>();
      case SecureNet:
        return allocator<SecureNet>().cast<T>();
      default:
        throw UnsupportedError('Unsupported type');
    }
  }

  @override
  void zeroOutPointer<T extends NativeType>(Pointer<T> pointer, int size) {
    final Pointer<Uint8> bytePointer = pointer.cast<Uint8>();
    final typeSize = _sizeOf<T>();
    for (var i = 0; i < size * typeSize; i++) {
      bytePointer[i] = 0;
    }
  }

  @override
  void free<T extends NativeType>(Pointer<T> pointer, [Allocator allocator = malloc]) {
    allocator.free(pointer);
  }

  @override
  void zeroOutAndFree<T extends NativeType>(Pointer<T> pointer, int size, {Allocator allocator = malloc}) {
    zeroOutPointer(pointer, size);
    free(pointer, allocator);
  }

  int _sizeOf<T extends NativeType>() {
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
      case const (Pointer<Char>):
        return sizeOf<Pointer<Char>>();
      case HiBONT:
        return sizeOf<HiBONT>();
      case SecureNet:
        return sizeOf<SecureNet>();
      default:
        throw UnsupportedError('Unsupported type');
    }
  }

  @override
  void uint8ListToPointer<T extends NativeType>(Pointer<T> pointer, Uint8List data) {
    final result = pointer.cast<Uint8>();

    for (var i = 0; i < data.length; i++) {
      result[i] = data[i];
    }
  }

  @override
  void stringToPointer<T extends NativeType>(Pointer<T> pointer, String data) {
    uint8ListToPointer<T>(pointer, Uint8List.fromList(utf8.encode(data)));
  }
}
