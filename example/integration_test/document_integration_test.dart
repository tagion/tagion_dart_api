import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/basic.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/document/document.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/document_error_code.dart';
import 'package:tagion_dart_api/enums/document_text_format.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/utils/ffi_library_util.dart';

void main() {
  final DynamicLibrary dyLib = FFILibraryUtil.load();
  BasicFfi basicFfi = BasicFfi(dyLib);
  basicFfi.start_rt();
  documentIntegrationTests(dyLib);
  // basicFfi.stop_rt();
}

void documentIntegrationTests(DynamicLibrary dyLib) {
  /// A real contract as a serialized HiBON.
  final hibonBuffer = Uint8List.fromList(base64Url.decode(
      '_QMBAiRABUhpUlBDAwIkWSEDGuaPS9u3r22WHd93J2uEquHBv_A4qE9g9ca5qxL5JrwCBCRtc2f9AhQCaWThzpPzBQEGbWV0aG9kBnN1Ym1pdAIGcGFyYW1z2wIBAiRAA1NTQwIJJGNvbnRyYWN0-QEBAiRAA1NNQwIDJGluJAMAACChE1h7ONUZg6hyDzwM1qqtf45FhgHKy8zWWgpN_sj2VwIEJHJ1br8BAQIkQANwYXkCBSR2YWxzrgECAABTAQIkQANUR04CAiRWChIBJICwr4yJoAEDAiRZIQLg1niES5tE941z3cyVO7ohtAZr4SAr11ZXFjMqRkXgzwkCJHTW8vHjpvar7ggDAiR4BMaIdRACAAFTAQIkQANUR04CAiRWChIBJICgt-yD_QADAiRZIQKYkUOPyywdDJ6G8OZ5eMLBKhvMhr4O3nuxfUiq1sO3BAkCJHSO6PTjpvar7ggDAiR4BPSQmA0CBiRzaWduc0QDAABAZRhWEMrAzAVqBJKa-pQIMf0O5PqDOLd62vzka6Z_MYaZq5rk39M47EdMeycnTNfGUot7Z1HdutgrNvcHme2KnAMFJHNpZ25AhgGz68Pq9LWPcnQPKeumtLYh0mGnnNsBk764abVvBYGthZDOYebP7zyz95wf-e2Kc7XqKOw3delXWcMwWXTEjA=='));

  late final BasicFfi basicFfi;
  late final DocumentFfi documentFfi;
  late final ErrorMessageFfi errorMessageFfi;
  late final IErrorMessage errorMessage;
  late final Basic basic;
  late final Document hibonDoc;

  /// FFI.
  basicFfi = BasicFfi(dyLib);
  documentFfi = DocumentFfi(dyLib);
  errorMessageFfi = ErrorMessageFfi(dyLib);

  errorMessage = ErrorMessage(errorMessageFfi, const PointerManager());
  basic = Basic(basicFfi, const PointerManager(), errorMessage);
  hibonDoc = Document(documentFfi, const PointerManager(), errorMessage, hibonBuffer);

  group('Document-DocumentFfi-DynamicLibrary Integration.', () {
    test("Validate the document", () {
      DocumentErrorCode errorCode = hibonDoc.validate();
      expect(errorCode, DocumentErrorCode.none);
    });

    test("Document as string in different text formats", () {
      String docAsJson = hibonDoc.getAsString(DocumentTextFormat.json);
      expect(docAsJson, isNotEmpty);
      String docAsPrettyJson = hibonDoc.getAsString(DocumentTextFormat.prettyJson);
      expect(docAsPrettyJson, isNotEmpty);
      String docAsBase64 = hibonDoc.getAsString(DocumentTextFormat.base64);
      expect(docAsBase64, isNotEmpty);
      String docAsHex = hibonDoc.getAsString(DocumentTextFormat.hex);
      expect(docAsHex, isNotEmpty);
    });

    test("Get a document's record name", () {
      String docRecName = hibonDoc.getRecordName();
      expect(docRecName, isNotEmpty);
    });

    test("Get a document's version", () {
      int docVersion = hibonDoc.getVersion();
      expect(docVersion, 0);
    });

    test("Read the document", () {
      /// "$@": "HiRPC"
      const atKey = '\$@';
      const typeTestValue = 'HiRPC';

      final atElement = hibonDoc.getElementByKey(atKey);
      String atResult = atElement.getString();
      expect(atResult, typeTestValue);

      /// "$Y": []
      const yKey = '\$Y';
      const pubKeyTestValue = '@Axrmj0vbt69tlh3fdydrhKrhwb_wOKhPYPXGuasS-Sa8';

      final yElement = hibonDoc.getElementByKey(yKey);
      Uint8List yElementBinary = yElement.getU8Array();
      String yResult = basic.encodeBase64Url(yElementBinary);
      expect(yResult, pubKeyTestValue);

      /// "$msg": {}
      const msgKey = '\$msg';
      final msgElement = hibonDoc.getElementByKey(msgKey);
      final msgBuffer = msgElement.getSubDocument();
      final msgDoc = Document(
        documentFfi,
        const PointerManager(),
        errorMessage,
        msgBuffer,
      );

      /// "id": []
      const idTestValue = 1583671137;
      final idElement = msgDoc.getElementByKey('id');
      final idResult = idElement.getUint32();
      expect(idResult, idTestValue);

      /// "params": {}
      const paramsKey = 'params';
      final paramsElement = msgDoc.getElementByKey(paramsKey);
      final paramsBuffer = paramsElement.getSubDocument();
      final paramsDoc = Document(
        documentFfi,
        const PointerManager(),
        errorMessage,
        paramsBuffer,
      );

      /// "$contract": {}
      const contractKey = '\$contract';
      final contractElement = paramsDoc.getElementByKey(contractKey);
      final contractBuffer = contractElement.getSubDocument();
      final contractDoc = Document(
        documentFfi,
        const PointerManager(),
        errorMessage,
        contractBuffer,
      );

      /// "$in": []
      const testKey4 = '\$in';
      final element4 = contractDoc.getElementByKey(testKey4);
      final inBuffer = element4.getSubDocument();
      final inDoc = Document(
        documentFfi,
        const PointerManager(),
        errorMessage,
        inBuffer,
      );

      const testIndex = 0;
      const dartIndexTestValue = '@oRNYezjVGYOocg88DNaqrX-ORYYBysvM1loKTf7I9lc=';

      final element5 = inDoc.getElementByIndex(testIndex);
      Uint8List elementBinary = element5.getU8Array();

      String dartIndexResult = basic.encodeBase64Url(elementBinary);
      expect(dartIndexResult, dartIndexTestValue);

      /// "$run" : {}
      const runKey = '\$run';
      final runElement = contractDoc.getElementByKey(runKey);
      final runBuffer = runElement.getSubDocument();
      final runDoc = Document(
        documentFfi,
        const PointerManager(),
        errorMessage,
        runBuffer,
      );

      /// "$vals": []
      const valsKey = '\$vals';
      final valsElement = runDoc.getElementByKey(valsKey);
      final valsBuffer = valsElement.getSubDocument();
      final valsDoc = Document(
        documentFfi,
        const PointerManager(),
        errorMessage,
        valsBuffer,
      );

      const valIndex = 0;
      final valElement = valsDoc.getElementByIndex(valIndex);
      final valBuffer = valElement.getSubDocument();
      final valDoc = Document(
        documentFfi,
        const PointerManager(),
        errorMessage,
        valBuffer,
      );

      /// "$t": []
      const tKey = '\$t';
      final tElement = valDoc.getElementByKey(tKey);
      expect(() => tElement.getTime(), returnsNormally);

      /// "$V": {}
      const vKey = '\$V';
      const vTestValue = 5500000000000;
      final vElement = valDoc.getElementByKey(vKey);
      final vBuffer = vElement.getSubDocument();
      final vDoc = Document(
        documentFfi,
        const PointerManager(),
        errorMessage,
        vBuffer,
      );

      /// "$": []
      const dolKey = '\$';
      final dolElement = vDoc.getElementByKey(dolKey);
      int vResult = dolElement.getInt64();
      expect(vResult, vTestValue);
    });
  });
}
