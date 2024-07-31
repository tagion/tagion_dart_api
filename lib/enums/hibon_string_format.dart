enum HibonAsStringFormat {
  json,
  prettyJson,
  base64,
  hex;

  const HibonAsStringFormat();
  factory HibonAsStringFormat.fromInt(int value) {
    return HibonAsStringFormat.values.firstWhere((e) => e.index == value);
  }
}
