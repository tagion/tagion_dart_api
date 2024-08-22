abstract interface class IScope {
  T onExit<T, E extends Exception>(int status, T Function() onDone, void Function()? onFinally);
}
