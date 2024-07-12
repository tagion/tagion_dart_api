enum DrtStatus {
  defaultStatus,
  started,
  terminated;

  const DrtStatus();
  factory DrtStatus.fromInt(int value) {
    return DrtStatus.values.firstWhere((e) => e.index == value);
  }
}
