import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/exception/tagion_exception.dart';

class BasicException extends TagionException {
  BasicException(TagionErrorCode errorCode, String message) : super(errorCode, message);
}
