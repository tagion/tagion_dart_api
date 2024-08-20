import 'dart:ffi';

abstract interface class IScope {
  T onExit<T, E extends Exception>(int status, T Function() onDone, List<Pointer> ptrs);
}
