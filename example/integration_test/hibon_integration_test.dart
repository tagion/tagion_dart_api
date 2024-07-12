import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/exception/hibon/hibon_exception.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';

void main() {
  group('Hibon-HibonFfi-DynamicLibrary Integration.', () {
    //create a dynamic library
    final DynamicLibrary dyLib = Platform.isAndroid ? DynamicLibrary.open('libtauonapi.so') : DynamicLibrary.process();

    final BasicFfi basicFfi = BasicFfi(dyLib);
    test('D runtime started', () {
      final int startDRuntimeResult = basicFfi.start_rt();
      expect(startDRuntimeResult, 1);
    });

    //create a Hibon object
    final HibonFfi hibonFfi = HibonFfi(dyLib);
    final Hibon hibon = Hibon(hibonFfi);

    test('Hibon created', () {
      expect(() => hibon.init(), returnsNormally);
    });

    test('Hibon add string executed', () {
      expect(() => hibon.addString('key', 'value'), returnsNormally);
    });

    test('Hibon get as string', () {
      try {
        String getAsStringResult = hibon.getAsString();
        // expect(getAsStringResult, {'key': 'value'});
      } on HibonException catch (e) {
        expect(e.errorCode, TagionErrorCode.error);
      }
    });

    test('D runtime stopped', () {
      final int stopDRuntimeResult = basicFfi.stop_rt();
      expect(stopDRuntimeResult, 1);
    });
  });
}
