import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/document/document.dart';
import 'package:tagion_dart_api/document/document_element.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/document/document_exception.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

class MockDocumentFfi extends Mock implements DocumentFfi {}

class MockPointerManager extends Mock implements IPointerManager {}

class MockErrorMessage extends Mock implements IErrorMessage {}

void main() {
  late MockDocumentFfi mockDocumentFfi;
  late MockPointerManager mockPointerManager;
  late MockErrorMessage mockErrorMessage;
  late Document document;
  final data = Uint8List.fromList([1, 2, 3]);

  setUp(() {
    registerFallbackValue('fallBackValue');
    registerFallbackValue(Pointer<Uint8>.fromAddress(0));
    registerFallbackValue(Pointer<Char>.fromAddress(0));
    registerFallbackValue(Pointer<Element>.fromAddress(0));
    registerFallbackValue(0);
    mockDocumentFfi = MockDocumentFfi();
    mockPointerManager = MockPointerManager();
    mockErrorMessage = MockErrorMessage();
    document = Document(mockDocumentFfi, mockPointerManager, mockErrorMessage, data: data);
  });

  group('Document', () {
    test('getDocument returns the correct DocumentElement and throws DocumentException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      final dataLen = data.lengthInBytes;
      const keyLen = key.length;

      final elementData = Uint8List.fromList([3, 4, 5]);
      final element = DocumentElement(elementData, key);

      final Pointer<Uint8> dataPtr = malloc<Uint8>(dataLen);
      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      final Pointer<Element> elementPtr = malloc<Element>();

      when(() => mockPointerManager.allocate<Uint8>(dataLen)).thenReturn(dataPtr);
      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);
      when(() => mockPointerManager.allocate<Element>()).thenReturn(elementPtr);

      when(() => mockDocumentFfi.tagion_document(any(), any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Uint8> dataPtr = invocation.positionalArguments[0];
        final Pointer<Char> keyPtr = invocation.positionalArguments[2];
        final Pointer<Element> elementPtr = invocation.positionalArguments[4];

        for (var i = 0; i < data.length; i++) {
          dataPtr[i] = data[i];
        }
        for (var i = 0; i < key.length; i++) {
          keyPtr[i] = key.codeUnitAt(i);
        }
        elementPtr.ref.data = malloc<Uint8>(elementData.length);
        for (var i = 0; i < elementData.length; i++) {
          elementPtr.ref.data[i] = elementData[i];
        }

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(dataPtr)).thenReturn(null);
      when(() => mockPointerManager.free(keyPtr)).thenReturn(null);
      when(() => mockPointerManager.free(elementPtr)).thenReturn(null);

      // Act
      final result = document.getDocument(key);

      // Assert
      expect(result.buffer, equals(element.buffer));
      expect(result.key, equals(element.key));

      // Verify
      verify(() => mockPointerManager.allocate<Uint8>(dataLen)).called(1);
      verify(() => mockPointerManager.uint8ListToPointer<Uint8>(dataPtr, data)).called(1);
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      verify(() => mockPointerManager.stringToPointer<Char>(keyPtr, key)).called(1);
      verify(() => mockDocumentFfi.tagion_document(dataPtr, dataLen, keyPtr, keyLen, elementPtr)).called(1);
      verify(() => mockPointerManager.free(dataPtr)).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);
      verify(() => mockPointerManager.free(elementPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document(any(), any(), any(), any(), any())).thenAnswer((invocation) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => document.getDocument(key),
        throwsA(isA<DocumentException>()
            .having(
              (e) => e.errorCode,
              '',
              equals(errorCode),
            )
            .having(
              (e) => e.message,
              '',
              equals(errorMessage),
            )),
      );

      // Verify
      verify(() => mockPointerManager.free(dataPtr)).called(1);
      verify(() => mockPointerManager.free(keyPtr)).called(1);
      verify(() => mockPointerManager.free(elementPtr)).called(1);
    });

    test('', () {
      // Arrange
      // Act
      // Assert
      // Verify
    });
  });
}
