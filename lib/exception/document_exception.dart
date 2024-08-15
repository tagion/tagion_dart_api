import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/exception/tagion_exception.dart';

class DocumentException extends TagionDartApiException {
  DocumentException(TagionErrorCode errorCode, String message) : super(errorCode, message);
}
