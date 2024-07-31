import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

void main() {
  final DynamicLibrary dyLib = Platform.isAndroid ? DynamicLibrary.open('libtauonapi.so') : DynamicLibrary.process();
  hibonIntegrationTest(dyLib);
}

void hibonIntegrationTest(DynamicLibrary dyLib) {
  group('Hibon-HibonFfi-DynamicLibrary Integration.', () {
    final ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    IErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);

    //create a Hibon object
    final HibonFfi hibonFfi = HibonFfi(dyLib);
    final Hibon hibon = Hibon(hibonFfi, errorMessage, pointerManager);

    test('Hibon created', () {
      expect(() => hibon.init(), returnsNormally);
    });

    test('Hibon adds string', () {
      expect(() => hibon.addString('key', 'value'), returnsNormally);
    });

    test('Hibon get as string', () {
      String hibonAsString = hibon.getAsString();
      expect(hibonAsString.contains('key') && hibonAsString.contains('value'), true);
    });
  });
}
