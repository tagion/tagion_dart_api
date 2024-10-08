import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/exception/tagion_exception.dart';

class HibonApiException extends TagionApiException {
  HibonApiException(TagionErrorCode errorCode, String message) : super(errorCode, message);
}
