import 'package:tagion_dart_api/enums/tagion_error_code.dart';

class TagionException implements Exception {
  final TagionErrorCode errorCode;
  final String message;

  TagionException(this.errorCode, this.message);
}
