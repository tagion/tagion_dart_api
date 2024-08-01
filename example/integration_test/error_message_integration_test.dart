import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
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

    group('getErrorText', () {
      test('is empty, when no errors', () {
        String errorText = errorMessage.getErrorText();
        expect(errorText, '');
      });

      test('returns correct error text', () {
        // run smth that will cause an error
        // check that the error text returns the correct text
      });
    });

    test('clearErrors clears the error text', () {
      // check that the error text returns same text as before
      // clear error text
      // check that the error text is empty
    });
  });
}
