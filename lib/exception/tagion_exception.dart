import 'package:tagion_dart_api/enums/tagion_error_code.dart';

class TagionApiException implements Exception {
  final TagionErrorCode errorCode;
  final String message;

  TagionApiException(this.errorCode, this.message);
}
