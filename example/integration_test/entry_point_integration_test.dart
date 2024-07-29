import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/basic.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

import 'basic_integration_test.dart';
import 'error_message_integration_test.dart';
import 'hibon_integration_test.dart';

void main() {
  group('Tagion Dart API integration tests:', () {
    final DynamicLibrary dyLib = Platform.isAndroid ? DynamicLibrary.open('libtauonapi.so') : DynamicLibrary.process();

    final BasicFfi basicFfi = BasicFfi(dyLib);
    final ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    final IErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);
    Basic basic = Basic(basicFfi, pointerManager, errorMessage);

    test('runtime started', () {
      final bool startDRuntimeResult = basic.startDRuntime();
      expect(startDRuntimeResult, true);
    });

    basicIntegrationTests(dyLib);
    errorMessageIntegrationTest(dyLib);
    hibonIntegrationTest(dyLib);

    test('runtime stopped', () {
      final bool stopDRuntimeResult = basic.stopDRuntime();
      expect(stopDRuntimeResult, true);
    });
  });
}
