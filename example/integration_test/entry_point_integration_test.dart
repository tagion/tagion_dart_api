import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/module/basic/basic.dart';
import 'package:tagion_dart_api/module/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/ffi_library_util.dart';

import 'basic_integration_test.dart';
import 'crypto_integration_test.dart';
import 'document_integration_test.dart';
import 'error_message_integration_test.dart';
import 'hibon_integration_test.dart';
import 'hirpc_integration_test.dart';

void main() {
  group('', () {
    final DynamicLibrary dyLib = DynamicLibraryLoader.load();

    final BasicFfi basicFfi = BasicFfi(dyLib);
    final ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    final IErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);
    Basic basic = Basic(basicFfi, pointerManager, errorMessage);

    test('D Runtime started', () {
      final bool startDRuntimeResult = basic.startDRuntime();
      expect(startDRuntimeResult, true);
    });

    // Error message integration test must be first to check that it returns an empty error message, when no errors occured yet.
    errorMessageIntegrationTest(dyLib);
    basicIntegrationTest(dyLib);
    cryptoIntegrationTest(dyLib);
    documentIntegrationTest(dyLib);
    hibonIntegrationTest(dyLib);
    hirpcIntegrationTest(dyLib);

    test('D runtime stopped', () {
      final bool stopDRuntimeResult = basic.stopDRuntime();
      expect(stopDRuntimeResult, true);
    });
  });
}
