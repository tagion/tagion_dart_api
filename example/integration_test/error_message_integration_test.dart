import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

void main() {
  group('ErrorMessage-DynamicLibrary Integration.', () {
    //create a dynamic library
    final DynamicLibrary dyLib = Platform.isAndroid ? DynamicLibrary.open('libtauonapi.so') : DynamicLibrary.process();

    final BasicFfi basicFfi = BasicFfi(dyLib);
    test('D runtime started', () {
      final int startDRuntimeResult = basicFfi.start_rt();
      expect(startDRuntimeResult, 1);
    });

    //create a ErrorMessage object
    final ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    final ErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);

    group('getErrorText -', () {
      test('is empty, when no errors', () {
        Hibon hibon = Hibon(HibonFfi(dyLib));
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

    test('D runtime stopped', () {
      final int stopDRuntimeResult = basicFfi.stop_rt();
      expect(stopDRuntimeResult, 1);
    });
  });
}
