enum TextFormat {
  json,
  prettyJson,
  base64,
  hex;

  const TextFormat();
  factory TextFormat.fromInt(int value) {
    return TextFormat.values.firstWhere((e) => e.index == value);
  }
}
