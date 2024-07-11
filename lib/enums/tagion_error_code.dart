enum TagionErrorCode {
  none(0),
  exception(-1),
  error(-2);

  final int value;
  const TagionErrorCode(this.value);

  factory TagionErrorCode.fromInt(int value) {
    return TagionErrorCode.values.firstWhere((e) => e.value == value);
  }
}
