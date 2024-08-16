import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/exception/basic_exception.dart';
import 'package:tagion_dart_api/exception/crypto_exception.dart';
import 'package:tagion_dart_api/exception/document_exception.dart';
import 'package:tagion_dart_api/exception/hibon_exception.dart';
import 'package:tagion_dart_api/exception/hirpc_exception.dart';
import 'package:tagion_dart_api/exception/tagion_exception.dart';

/// Factory class to create exceptions based on the [TagionApiException]
/// Cannot be instantiated.
class ExceptionFactory {
  ExceptionFactory._();

  static TagionApiException create<T extends Exception>(TagionErrorCode errorCode, String message) {
    switch (T) {
      case BasicApiException:
        return BasicApiException(errorCode, message);
      case HibonApiException:
        return HibonApiException(errorCode, message);
      case HiRPCApiException:
        return HiRPCApiException(errorCode, message);
      case DocumentApiException:
        return DocumentApiException(errorCode, message);
      case CryptoApiException:
        return CryptoApiException(errorCode, message);
      default:
        return TagionApiException(errorCode, message);
    }
  }
}
