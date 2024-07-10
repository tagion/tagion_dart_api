import 'dart:ffi' as ffi;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/error/error.dart';
import 'package:tagion_dart_api/error/ffi/error_ffi.dart';

class MockErrorsFfi extends Mock implements ErrorFfi {}

void main() {
  group('FFIErrorsApi', () {
    late MockErrorsFfi mockErrorsFfi;
    late Error ffiError;

    setUp(() {
      registerFallbackValue(ffi.Pointer<ffi.Char>.fromAddress(0));
      registerFallbackValue(ffi.Pointer<ffi.Uint64>.fromAddress(0));
      mockErrorsFfi = MockErrorsFfi();
      ffiError = Error(mockErrorsFfi);
    });

    test('getErrorMessage returns the correct error message', () {
      // Allocate memory for the mocked error message
      const msg = 'Mocked error message';

      // Mock the FFI function call
      when(() => mockErrorsFfi.tagion_error_text(any(), any())).thenAnswer((invocation) {
        final ffi.Pointer<ffi.Char> charPtr = invocation.positionalArguments[0];
        final ffi.Pointer<ffi.Uint64> lengthPtr = invocation.positionalArguments[1];
        for (var i = 0; i < msg.length; i++) {
          charPtr[i] = msg.codeUnitAt(i);
        }
        lengthPtr.value = msg.length;
      });

      // Call the method
      final errorMessage = ffiError.getErrorMessage();

      // Check the result
      expect(errorMessage, msg);
    });
  });
}
