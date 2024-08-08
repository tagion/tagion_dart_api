import 'package:tagion_dart_api/enums/tagion_error_code.dart';

class TagionDartApiException implements Exception {
  final TagionErrorCode errorCode;
  final String message;

  TagionDartApiException(this.errorCode, this.message);
}
