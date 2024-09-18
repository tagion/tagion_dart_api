import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/module/basic/basic.dart';
import 'package:tagion_dart_api/module/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/dynamic_library_loader.dart';

void main() {
  final DynamicLibrary dyLib = DynamicLibraryLoader.load();
  BasicFfi basicFfi = BasicFfi(dyLib);
  setUpAll(() {
    basicFfi.start_rt();
  });

  basicIntegrationTest(dyLib);

  tearDownAll(() {
    basicFfi.stop_rt();
  });
}

void basicIntegrationTest(DynamicLibrary dyLib) {
  group('Basic-BasicFfi-Binary Integration.', () {
    final BasicFfi basicFfi = BasicFfi(dyLib);
    final ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    final IErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);
    Basic basic = Basic(basicFfi, pointerManager, errorMessage);

    // functions that start and stop D runtime are tested in the entry_point_integration_test.dart in the beginning and at the end of all integration tests

    test('returned correct base64url', () {
      const String testString = '<<???>>';
      // Base64URL uses the same algorithm as the base64 standard, but differs in the following:
      // Replaces “+” by “-” (minus)
      // Replaces “/” by “_” (underline)
      // Does not require a padding character
      // Forbids line separators
      const String expectedString = '@PDw_Pz8-Pg==';
      final Uint8List testBytes = Uint8List.fromList(testString.codeUnits);
      final String base64Url = basic.encodeBase64Url(testBytes);
      expect(base64Url, expectedString);
    });

    test('returned revision', () {
      final String revision = basic.tagionRevision();
      expect(revision, isNotEmpty);
    });

    test('created dart index', () {
      final Uint8List expectedIndexBytes = base64Url.decode('OtVPyrElTZubexga9J_AQFpbIjmbsxFaWZZoImBNL_0=');
      final Uint8List docBytes = base64Url.decode('CwEDa2V5BXZhbHVl');

      final index = basic.createDartIndex(docBytes);
      expect(index, expectedIndexBytes);
    });
  });
}
