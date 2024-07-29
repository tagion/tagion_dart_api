import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/document/document.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/document_text_format.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

/// TODO: Add a test.
void main() {
  group('Document-DocumentFfi-DynamicLibrary Integration.', () {
    final DynamicLibrary dyLib = Platform.isAndroid ? DynamicLibrary.open('libtauonapi.so') : DynamicLibrary.process();

    
    final DocumentFfi documentFfi = DocumentFfi(dyLib);
    final ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    final IErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);

    test('Read a Document', () {
      final documentData = Uint8List.fromList(base64Url.decode(
          '_QMBAiRABUhpUlBDAwIkWSEDGuaPS9u3r22WHd93J2uEquHBv_A4qE9g9ca5qxL5JrwCBCRtc2f9AhQCaWThzpPzBQEGbWV0aG9kBnN1Ym1pdAIGcGFyYW1z2wIBAiRAA1NTQwIJJGNvbnRyYWN0-QEBAiRAA1NNQwIDJGluJAMAACChE1h7ONUZg6hyDzwM1qqtf45FhgHKy8zWWgpN_sj2VwIEJHJ1br8BAQIkQANwYXkCBSR2YWxzrgECAABTAQIkQANUR04CAiRWChIBJICwr4yJoAEDAiRZIQLg1niES5tE941z3cyVO7ohtAZr4SAr11ZXFjMqRkXgzwkCJHTW8vHjpvar7ggDAiR4BMaIdRACAAFTAQIkQANUR04CAiRWChIBJICgt-yD_QADAiRZIQKYkUOPyywdDJ6G8OZ5eMLBKhvMhr4O3nuxfUiq1sO3BAkCJHSO6PTjpvar7ggDAiR4BPSQmA0CBiRzaWduc0QDAABAZRhWEMrAzAVqBJKa-pQIMf0O5PqDOLd62vzka6Z_MYaZq5rk39M47EdMeycnTNfGUot7Z1HdutgrNvcHme2KnAMFJHNpZ25AhgGz68Pq9LWPcnQPKeumtLYh0mGnnNsBk764abVvBYGthZDOYebP7zyz95wf-e2Kc7XqKOw3delXWcMwWXTEjA=='));

      Document document = Document(
        documentFfi,
        pointerManager,
        errorMessage,
        documentData,
      );

      // document.getElementByKey('key');
      // document.getElementByIndex(index: 0);
      // document.getRecordName();
      // document.validate();
      String docAsStr = document.getAsString(DocumentTextFormat.json);
      print(docAsStr);
    });
  });
}
