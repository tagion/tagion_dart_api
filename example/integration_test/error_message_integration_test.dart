import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

void errorMessageIntegrationTest(DynamicLibrary dyLib) {
  group('ErrorMessage-DynamicLibrary Integration.', () {
    //create a ErrorMessage object
    final ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    final ErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);

    group('getErrorText -', () {
      test('is empty, when no errors', () {
        Hibon hibon = Hibon(HibonFfi(dyLib), errorMessage, pointerManager);
        hibon.init();

        String errorText = errorMessage.getErrorText();
        expect(errorText, '');
      });

      // test('-returns correct error text', () {
      //   Hibon hibon = Hibon(HibonFfi(dyLib));
      //   try {
      //     hibon.getAsString();
      //   } on HibonException catch (e) {
      //     expect(e.errorCode, TagionErrorCode.exception);
      //   }
      //   String errorText = errorMessage.getErrorText();
      //   expect(errorText, '');
      // });
    });

    // test('clearErrors clears the error text', () {});
  });
}
