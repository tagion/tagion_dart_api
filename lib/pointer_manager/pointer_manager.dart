import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'pointer_manager_interface.dart';

/// Object class providing methods to allocate, zero out, and free memory.
class PointerManager implements IPointerManager {
  const PointerManager();

  @override
  Pointer<T> allocate<T extends NativeType>([int size = 1, Allocator allocator = malloc]) {
    return allocator.allocate<T>(size);
  }

  @override
  void zeroOutPointer(Pointer pointer, int size) {
    final bytePointer = pointer.cast<Uint8>();
    final typeSize = sizeOf<Uint8>();
    for (var i = 0; i < size * typeSize; i++) {
      bytePointer[i] = 0;
    }
  }

  @override
  void free(Pointer pointer, [Allocator allocator = malloc]) {
    allocator.free(pointer);
  }

  @override
  void freeAll(List<Pointer> pointers, [Allocator allocator = malloc]) {
    for (var ptr in pointers) {
      free(ptr, allocator);
    }
  }

  @override
  void zeroOutAndFree(Pointer pointer, int size, [Allocator allocator = malloc]) {
    zeroOutPointer(pointer, size);
    free(pointer, allocator);
  }

  @override
  void uint8ListToPointer<T extends NativeType>(Pointer<T> pointer, Uint8List data) {
    final bytePointer = pointer.cast<Uint8>();

    for (var i = 0; i < data.length; i++) {
      bytePointer[i] = data[i];
    }
  }

  @override
  void stringToPointer<T extends NativeType>(Pointer<T> pointer, String data) {
    uint8ListToPointer<T>(pointer, Uint8List.fromList(utf8.encode(data)));
  }
}
