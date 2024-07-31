import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart'; // Import the interface and implementation

// Mock classes
class MockErrorsMessageFfi extends Mock implements ErrorMessageFfi {}

class MockPointerManager extends Mock implements IPointerManager {}

void main() {
  group('ErrorMessage Unit.', () {
    late MockErrorsMessageFfi mockErrorMessageFfi;
    late MockPointerManager mockPointerManager;
    late IErrorMessage errorMessage;

    setUp(() {
      registerFallbackValue(Pointer<Char>.fromAddress(0));
      registerFallbackValue(Pointer<Uint64>.fromAddress(0));
      registerFallbackValue(0);
      mockErrorMessageFfi = MockErrorsMessageFfi();
      mockPointerManager = MockPointerManager();
      errorMessage = ErrorMessage(mockErrorMessageFfi, mockPointerManager);
    });

    test('GetErrorText returns the correct error text', () {
      // Allocate memory for the mocked error message
      const testValue = 'Mocked error message';
      final Pointer<Pointer<Char>> msgPtr = malloc<Pointer<Char>>(1);
      final Pointer<Uint64> msgLenPtr = malloc<Uint64>(sizeOf<Uint64>());

      // Mock the PointerManager methods
      when(() => mockPointerManager.allocate<Pointer<Char>>()).thenReturn(msgPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(msgLenPtr);
      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Mock the FFI function call
      when(() => mockErrorMessageFfi.tagion_error_text(any(), any())).thenAnswer((invocation) {
        (invocation.positionalArguments[0] as Pointer<Pointer<Char>>)[0] = testValue.toNativeUtf8().cast<Char>();
        (invocation.positionalArguments[1] as Pointer<Uint64>)[0] = testValue.length;
      });

      // Call the method
      final result = errorMessage.getErrorText();

      // Check the result
      expect(result, testValue);

      // Verify the interactions
      verify(() => mockPointerManager.allocate<Pointer<Char>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockPointerManager.free(msgPtr)).called(1);
      verify(() => mockPointerManager.free(msgLenPtr)).called(1);
    });

    test('clearErrors calls the correct FFI function', () {
      when(() => mockErrorMessageFfi.tagion_clear_error()).thenReturn(null);
      errorMessage.clearErrors();
      verify(() => mockErrorMessageFfi.tagion_clear_error()).called(1);
    });
  });
}
