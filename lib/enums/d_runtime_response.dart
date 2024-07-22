enum DRuntimeResponse {
  failed,
  success;

  const DRuntimeResponse();
  factory DRuntimeResponse.fromInt(int value) {
    return DRuntimeResponse.values.firstWhere((e) => e.index == value);
  }
}
