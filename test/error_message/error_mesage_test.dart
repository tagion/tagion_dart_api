import 'dart:ffi' as ffi;

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
  group('ErrorMessage.', () {
    late MockErrorsMessageFfi mockErrorMessageFfi;
    late MockPointerManager mockPointerManager;
    late IErrorMessage errorMessage;

    setUp(() {
      registerFallbackValue(ffi.Pointer<ffi.Char>.fromAddress(0));
      registerFallbackValue(ffi.Pointer<ffi.Uint64>.fromAddress(0));
      registerFallbackValue(0);
      mockErrorMessageFfi = MockErrorsMessageFfi();
      mockPointerManager = MockPointerManager();
      errorMessage = ErrorMessage(mockErrorMessageFfi, mockPointerManager);
    });

    test('GetErrorText returns the correct error text', () {
      // Allocate memory for the mocked error message
      const msg = 'Mocked error message';
      final ffi.Pointer<ffi.Char> msgPtr = malloc<ffi.Char>(msg.length);
      final ffi.Pointer<ffi.Uint64> msgLenPtr = malloc<ffi.Uint64>(ffi.sizeOf<ffi.Uint64>());

      // Mock the PointerManager methods
      when(() => mockPointerManager.allocate<ffi.Char>()).thenReturn(msgPtr);
      when(() => mockPointerManager.allocate<ffi.Uint64>()).thenReturn(msgLenPtr);
      when(() => mockPointerManager.free<ffi.Char>(any())).thenReturn(null);
      when(() => mockPointerManager.free<ffi.Uint64>(any())).thenReturn(null);

      // Mock the FFI function call
      when(() => mockErrorMessageFfi.tagion_error_text(any(), any())).thenAnswer((invocation) {
        final ffi.Pointer<ffi.Char> charPtr = invocation.positionalArguments[0];
        final ffi.Pointer<ffi.Uint64> lengthPtr = invocation.positionalArguments[1];
        for (var i = 0; i < msg.length; i++) {
          charPtr[i] = msg.codeUnitAt(i);
        }
        lengthPtr.value = msg.length;
      });

      // Call the method
      final result = errorMessage.getErrorText();

      // Check the result
      expect(result, msg);

      // Verify the interactions
      verify(() => mockPointerManager.allocate<ffi.Char>()).called(1);
      verify(() => mockPointerManager.allocate<ffi.Uint64>()).called(1);
      verify(() => mockPointerManager.free<ffi.Char>(msgPtr)).called(1);
      verify(() => mockPointerManager.free<ffi.Uint64>(msgLenPtr)).called(1);
    });

    test('clearErrors calls the correct FFI function', () {
      when(() => mockErrorMessageFfi.tagion_clear_error()).thenReturn(null);
      errorMessage.clearErrors();
      verify(() => mockErrorMessageFfi.tagion_clear_error()).called(1);
    });
  });
}
