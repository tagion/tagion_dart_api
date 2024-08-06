import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/exception/hibon_exception.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/ffi_library_util.dart';

void main() {
  final DynamicLibrary dyLib = FFILibraryUtil.load();
  BasicFfi basicFfi = BasicFfi(dyLib);
  setUpAll(() {
    basicFfi.start_rt();
  });

  errorMessageIntegrationTest(dyLib);

  tearDownAll(() {
    basicFfi.stop_rt();
  });
}

void errorMessageIntegrationTest(DynamicLibrary dyLib) {
  group('ErrorMessage-DynamicLibrary Integration.', () {
    //create a ErrorMessage object
    final ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    final ErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);

    // Arrange
    const TagionErrorCode errorCode = TagionErrorCode.exception;
    const String expectdErrorText = "Element member key already exists";

    group('getErrorText', () {
      test('returns an empty string, when no errors', () {
        String errorText = errorMessage.getErrorText();
        expect(errorText, '');
      });

      test('returns a correct error text', () {
        Hibon hibon = Hibon(HibonFfi(dyLib), errorMessage, const PointerManager());
        hibon.create();
        hibon.addString('key', 'value');
        expect(
          () => hibon.addString('key', 'value'),
          throwsA(isA<HibonException>()
              .having(
                (e) => e.errorCode,
                '',
                equals(errorCode),
              )
              .having(
                (e) => e.message,
                '',
                equals(expectdErrorText),
              )),
        );
      });
    });

    test('clearErrors clears the error text', () {
      String errorText = errorMessage.getErrorText();
      expect(errorText, errorText);

      errorMessage.clearErrors();
      errorText = errorMessage.getErrorText();
      expect(errorText, '');
    });
  });
}
