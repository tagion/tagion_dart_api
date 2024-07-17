enum DocumentTextFormat {
  json,
  prettyJson,
  base64,
  hex;

  const DocumentTextFormat();
  factory DocumentTextFormat.fromInt(int value) {
    return DocumentTextFormat.values.firstWhere((e) => e.index == value);
  }
}
