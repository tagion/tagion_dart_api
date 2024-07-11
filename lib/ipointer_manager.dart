import 'dart:ffi';

abstract interface class IPointerManager {
  /// Method to allocate and initialize memory.
  Pointer<T> allocate<T extends NativeType>(int size, {Allocator allocator});

  /// Method to zero out the memory pointed to by the pointer.
  void zeroOutPointer<T extends NativeType>(Pointer<T> pointer, int size);

  /// Method to free the memory.
  void free<T extends NativeType>(Pointer<T> pointer, {Allocator allocator});

  /// Method to zero out and free the memory.
  void zeroOutAndFree<T extends NativeType>(Pointer<T> pointer, int size, {Allocator allocator});
}