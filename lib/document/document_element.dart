import 'dart:typed_data';

class DocumentElement{
  final Uint8List buffer;
  final String key;

  const DocumentElement(this.buffer, this.key);
}