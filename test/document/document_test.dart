import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/module/document/document.dart';
import 'package:tagion_dart_api/module/document/element/document_element.dart';
import 'package:tagion_dart_api/module/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/document_error_code.dart';
import 'package:tagion_dart_api/enums/text_format.dart';
import 'package:tagion_dart_api/enums/tagion_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/exception/document_exception.dart';
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
  final dataLen = data.lengthInBytes;
  final Pointer<Uint8> dataPtr = malloc<Uint8>(data.lengthInBytes);

  setUp(() {
    registerFallbackValue('fallBackValue');
    registerFallbackValue(Pointer<Uint8>.fromAddress(0));
    registerFallbackValue(Pointer<Char>.fromAddress(0));
    registerFallbackValue(Pointer<Element>.fromAddress(0));
    registerFallbackValue(0);
    mockDocumentFfi = MockDocumentFfi();
    mockPointerManager = MockPointerManager();
    mockErrorMessage = MockErrorMessage();
    when(() => mockPointerManager.allocate<Uint8>(data.lengthInBytes)).thenReturn(dataPtr);
    document = Document(mockDocumentFfi, mockPointerManager, mockErrorMessage, data);
  });

  group('Document Unit', () {
    test('getElementByKey returns the correct DocumentElement and throws DocumentException when an error occurs', () {
      // Arrange
      const key = 'testKey';
      const keyLen = key.length;

      final elementData = Uint8List.fromList([3, 4, 5]);

      final Pointer<Char> keyPtr = malloc<Char>(keyLen);
      final Pointer<Element> elementPtr = malloc<Element>();

      when(() => mockPointerManager.allocate<Char>(keyLen)).thenReturn(keyPtr);
      when(() => mockPointerManager.allocate<Element>()).thenReturn(elementPtr);

      when(() => mockDocumentFfi.tagion_document_element_by_key(any(), any(), any(), any(), any()))
          .thenAnswer((invocation) {
        final Pointer<Char> keyPtr = invocation.positionalArguments[2];
        final Pointer<Element> elementPtr = invocation.positionalArguments[4];

        for (var i = 0; i < key.length; i++) {
          keyPtr[i] = key.codeUnitAt(i);
        }
        elementPtr.ref.data = malloc<Uint8>(elementData.length);
        for (var i = 0; i < elementData.length; i++) {
          elementPtr.ref.data[i] = elementData[i];
        }

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act
      final result = document.getElementByKey(key);

      // Assert
      expect((result as DocumentElement).elementPtr.ref.data.asTypedList(elementData.length),
          equals(Uint8List.fromList(elementData)));

      // Verify
      verify(() => mockPointerManager.allocate<Char>(keyLen)).called(1);
      verify(() => mockPointerManager.stringToPointer<Char>(keyPtr, key)).called(1);
      verify(() => mockDocumentFfi.tagion_document_element_by_key(dataPtr, dataLen, keyPtr, keyLen, elementPtr))
          .called(1);
      verify(() => mockPointerManager.free(any())).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_element_by_key(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => document.getElementByKey(key),
        throwsA(isA<DocumentApiException>()
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
      verify(() => mockPointerManager.free(any())).called(1);
    });

    test('getElementByIndex returns the correct DocumentElement and throws DocumentException when an error occurs', () {
      // Arrange
      const int index = 1;

      final elementData = Uint8List.fromList([3, 4, 5]);
      final Pointer<Element> elementPtr = malloc<Element>();

      when(() => mockPointerManager.allocate<Element>()).thenReturn(elementPtr);

      when(() => mockDocumentFfi.tagion_document_element_by_index(any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Element> elementPtr = invocation.positionalArguments[3];

        elementPtr.ref.data = malloc<Uint8>(elementData.length);
        for (var i = 0; i < elementData.length; i++) {
          elementPtr.ref.data[i] = elementData[i];
        }

        return TagionErrorCode.none.value;
      });

      // Act
      final result = document.getElementByIndex(index);

      // Assert
      expect((result as DocumentElement).elementPtr.ref.data.asTypedList(elementData.length),
          equals(Uint8List.fromList(elementData)));

      // Verify
      verify(() => mockDocumentFfi.tagion_document_element_by_index(dataPtr, dataLen, index, elementPtr)).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_element_by_index(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => document.getElementByIndex(index),
        throwsA(isA<DocumentApiException>()
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
    });

    test('getVersion return a correct version and throws DocumentException when an error occurs', () {
      // Arrange
      const version = 1;

      final Pointer<Uint32> versionPtr = malloc<Uint32>();
      when(() => mockPointerManager.allocate<Uint32>()).thenReturn(versionPtr);
      when(() => mockDocumentFfi.tagion_document_get_version(any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Uint32> versionPtr = invocation.positionalArguments[2];

        versionPtr.value = version;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);
      // Act
      final result = document.getVersion();
      // Assert
      expect(result, equals(version));
      // Verify
      verify(() => mockPointerManager.allocate<Uint8>(dataLen)).called(1);
      verify(() => mockPointerManager.allocate<Uint32>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_version(dataPtr, dataLen, versionPtr)).called(1);
      verify(() => mockPointerManager.free(any())).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_version(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => document.getVersion(),
        throwsA(isA<DocumentApiException>()
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
      verify(() => mockPointerManager.free(any())).called(1);
    });

    test('validate returns a correct DocumentErrorCode and throws DocumentException when an error occurs', () {
      // Arrange
      const docErrorCode = DocumentErrorCode.none;

      final Pointer<Int32> docErrorCodePtr = malloc<Int32>();

      when(() => mockPointerManager.allocate<Int32>()).thenReturn(docErrorCodePtr);
      when(() => mockDocumentFfi.tagion_document_valid(any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Uint32> docErrorCodePtr = invocation.positionalArguments[2];

        docErrorCodePtr.value = docErrorCode.index;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.free(any())).thenReturn(null);
      // Act
      final result = document.validate();
      // Assert
      expect(result.index, equals(docErrorCode.index));
      // Verify
      verify(() => mockPointerManager.allocate<Int32>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_valid(dataPtr, dataLen, docErrorCodePtr)).called(1);
      verify(() => mockPointerManager.free(any())).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_valid(any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => document.validate(),
        throwsA(isA<DocumentApiException>()
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
      verify(() => mockPointerManager.free(any())).called(1);
    });

    test('getAsString returns a correct value and throws DocumentException when an error occurs', () {
      // Arrange
      const text = 'Test text';
      final Pointer<Utf8> textUtf8Ptr = text.toNativeUtf8();
      const textFormat = TextFormat.base64;

      final Pointer<Pointer<Char>> textPtr = malloc<Pointer<Char>>();
      final Pointer<Uint64> textLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Pointer<Char>>()).thenReturn(textPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(textLenPtr);

      when(() => mockDocumentFfi.tagion_document_get_text(any(), any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Char>> textPtr = invocation.positionalArguments[3];
        final Pointer<Uint64> textLenPtr = invocation.positionalArguments[4];

        textPtr.value = textUtf8Ptr.cast<Char>();
        textLenPtr.value = textUtf8Ptr.length;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.freeAll(any())).thenReturn(null);
      // Act
      final result = document.getAsString(textFormat);
      // Assert
      expect(result, equals(text));
      // Verify
      verify(() => mockPointerManager.allocate<Uint8>(dataLen)).called(1);
      verify(() => mockPointerManager.allocate<Pointer<Char>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_text(dataPtr, dataLen, textFormat.index, textPtr, textLenPtr))
          .called(1);
      verify(() => mockPointerManager.freeAll(any())).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_text(any(), any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => document.getAsString(textFormat),
        throwsA(isA<DocumentApiException>()
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
      verify(() => mockPointerManager.freeAll(any())).called(1);
    });

    test('getRecordName returns a correct value and throws DocumentException when an error occurs', () {
      // Arrange
      const text = 'Test record name';
      final Pointer<Utf8> textUtf8Ptr = text.toNativeUtf8();

      final Pointer<Pointer<Char>> textPtr = malloc<Pointer<Char>>();
      final Pointer<Uint64> textLenPtr = malloc<Uint64>();

      when(() => mockPointerManager.allocate<Pointer<Char>>()).thenReturn(textPtr);
      when(() => mockPointerManager.allocate<Uint64>()).thenReturn(textLenPtr);

      when(() => mockDocumentFfi.tagion_document_get_record_name(any(), any(), any(), any())).thenAnswer((invocation) {
        final Pointer<Pointer<Char>> textPtr = invocation.positionalArguments[2];
        final Pointer<Uint64> textLenPtr = invocation.positionalArguments[3];

        textPtr.value = textUtf8Ptr.cast<Char>();
        textLenPtr.value = textUtf8Ptr.length;

        return TagionErrorCode.none.value;
      });

      when(() => mockPointerManager.freeAll(any())).thenReturn(null);
      // Act
      final result = document.getRecordName();
      // Assert
      expect(result, equals(text));
      // Verify
      verify(() => mockPointerManager.allocate<Uint8>(dataLen)).called(1);
      verify(() => mockPointerManager.allocate<Pointer<Char>>()).called(1);
      verify(() => mockPointerManager.allocate<Uint64>()).called(1);
      verify(() => mockDocumentFfi.tagion_document_get_record_name(dataPtr, dataLen, textPtr, textLenPtr)).called(1);
      verify(() => mockPointerManager.freeAll(any())).called(1);

      // Arrange
      const errorCode = TagionErrorCode.error;
      const errorMessage = "Error message";
      when(() => mockErrorMessage.getErrorText()).thenReturn(errorMessage);

      when(() => mockDocumentFfi.tagion_document_get_record_name(any(), any(), any(), any())).thenAnswer((_) {
        return TagionErrorCode.error.value;
      });

      // Act & Assert
      expect(
        () => document.getRecordName(),
        throwsA(isA<DocumentApiException>()
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
      verify(() => mockPointerManager.freeAll(any())).called(1);
    });

    test('dispose calls tagion_hibon_free', () {
      // Arrange
      when(() => mockPointerManager.free(any())).thenReturn(null);

      // Act & Assert
      expect(() => document.dispose(), returnsNormally);

      // Verify
      verify(() => mockPointerManager.free(any())).called(1);
    });
  });
}
