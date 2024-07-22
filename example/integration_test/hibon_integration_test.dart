import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/enums/d_runtime_response.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

void main() {
  group('Hibon-HibonFfi-DynamicLibrary Integration.', () {
    //create a dynamic library
    final DynamicLibrary dyLib = Platform.isAndroid ? DynamicLibrary.open('libtauonapi.so') : DynamicLibrary.process();

    final BasicFfi basicFfi = BasicFfi(dyLib);
    final ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    IErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);

    test('D runtime started', () {
      final int startDRuntimeResult = basicFfi.start_rt();
      expect(startDRuntimeResult, DRuntimeResponse.success.index);
    });

    //create a Hibon object
    final HibonFfi hibonFfi = HibonFfi(dyLib);
    final Hibon hibon = Hibon(hibonFfi, errorMessage, pointerManager);

    test('Hibon created', () {
      expect(() => hibon.init(), returnsNormally);
    });

    // test('Hibon add string executed', () {
    //   expect(() => hibon.addString('key', 'value'), returnsNormally);
    // });

    // test('Hibon get as string', () {
    //   try {
    //     String getAsStringResult = hibon.getAsString();
    //     // expect(getAsStringResult, {'key': 'value'});
    //   } on HibonException catch (e) {
    //     expect(e.errorCode, TagionErrorCode.error);
    //   }
    // });

    test('D runtime stopped', () {
      final int stopDRuntimeResult = basicFfi.stop_rt();
      expect(stopDRuntimeResult, 1);
    });
  });
}
