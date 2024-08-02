import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/document/document.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/hibon/ffi/hibon_ffi.dart';
import 'package:tagion_dart_api/hibon/hibon.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/ffi_library_util.dart';

void main() {
  final DynamicLibrary dyLib = FFILibraryUtil.load();
  BasicFfi basicFfi = BasicFfi(dyLib);
  setUpAll(() {
    basicFfi.start_rt();
  });

  hibonIntegrationTest(dyLib);

  tearDownAll(() {
    basicFfi.stop_rt();
  });
}

void hibonIntegrationTest(DynamicLibrary dyLib) {
  group('Hibon-HibonFfi-DynamicLibrary Integration.', () {
    final ErrorMessageFfi errorMessageFfi = ErrorMessageFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    IErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);

    //create a Hibon object
    final HibonFfi hibonFfi = HibonFfi(dyLib);
    final Hibon hibon = Hibon(hibonFfi, errorMessage, pointerManager);
    final hibonBuffer = Uint8List.fromList(base64Url.decode(
        '_QMBAiRABUhpUlBDAwIkWSEDGuaPS9u3r22WHd93J2uEquHBv_A4qE9g9ca5qxL5JrwCBCRtc2f9AhQCaWThzpPzBQEGbWV0aG9kBnN1Ym1pdAIGcGFyYW1z2wIBAiRAA1NTQwIJJGNvbnRyYWN0-QEBAiRAA1NNQwIDJGluJAMAACChE1h7ONUZg6hyDzwM1qqtf45FhgHKy8zWWgpN_sj2VwIEJHJ1br8BAQIkQANwYXkCBSR2YWxzrgECAABTAQIkQANUR04CAiRWChIBJICwr4yJoAEDAiRZIQLg1niES5tE941z3cyVO7ohtAZr4SAr11ZXFjMqRkXgzwkCJHTW8vHjpvar7ggDAiR4BMaIdRACAAFTAQIkQANUR04CAiRWChIBJICgt-yD_QADAiRZIQKYkUOPyywdDJ6G8OZ5eMLBKhvMhr4O3nuxfUiq1sO3BAkCJHSO6PTjpvar7ggDAiR4BPSQmA0CBiRzaWduc0QDAABAZRhWEMrAzAVqBJKa-pQIMf0O5PqDOLd62vzka6Z_MYaZq5rk39M47EdMeycnTNfGUot7Z1HdutgrNvcHme2KnAMFJHNpZ25AhgGz68Pq9LWPcnQPKeumtLYh0mGnnNsBk764abVvBYGthZDOYebP7zyz95wf-e2Kc7XqKOw3delXWcMwWXTEjA=='));

    test('Hibon adds values of all supported standard types', () {
      expect(() => hibon.addString('key1', 'value'), returnsNormally);
      expect(() => hibon.addBool('key2', true), returnsNormally);
      expect(() => hibon.addInt<Int32>('key3', 10), returnsNormally);
      expect(() => hibon.addInt<Int64>('key4', 9223372036854775807), returnsNormally);
      expect(() => hibon.addInt<Uint32>('key5', -10), returnsNormally);
      expect(() => hibon.addInt<Uint64>('key6', -9223372036854775808), returnsNormally);
      expect(() => hibon.addFloat<Float>('key7', 123.456), returnsNormally);
      expect(() => hibon.addFloat<Double>('key8', 123.456), returnsNormally);
      expect(() => hibon.addTime('key9', 638578428038904150), returnsNormally);
      expect(() => hibon.addBigint('key10', BigInt.from(9223372036854775807)), returnsNormally);
      expect(() => hibon.addArrayByKey('key11', Uint8List.fromList([1, 2, 3])), returnsNormally);
    });

    test('Hibon adds values of all supported custom types', () {
      /// Hibon test.
      final Hibon nestedHibon = Hibon(hibonFfi, errorMessage, pointerManager);
      nestedHibon.addString('key1', 'value');

      expect(() => hibon.addHibonByKey('key12', nestedHibon), returnsNormally);

      /// Document test.
      final document = Document(DocumentFfi(dyLib), pointerManager, errorMessage, hibonBuffer);

      expect(() => hibon.addDocumentByKey('key13', document), returnsNormally);
      expect(() => hibon.addDocumentBufferByKey('key14', hibonBuffer), returnsNormally);
    });

    test('Get hibon as a document', () {
      expect(() => hibon.getDocument(), returnsNormally);
    });

    test('Hibon get as a string', () {
      expect(hibon.getAsString(), isNotEmpty);
    });

    test('Hibon disposes normally', () {
      expect(() => hibon.dispose(), returnsNormally);
    });
  });
}
