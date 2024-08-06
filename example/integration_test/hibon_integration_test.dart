import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
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
    final IErrorMessage errorMessage = ErrorMessage(errorMessageFfi, pointerManager);

    //create a Hibon object
    final HibonFfi hibonFfi = HibonFfi(dyLib);
    final Hibon hibon = Hibon(hibonFfi, errorMessage, pointerManager);
    final hibonBuffer = Uint8List.fromList(base64Url.decode(
        '_QMBAiRABUhpUlBDAwIkWSEDGuaPS9u3r22WHd93J2uEquHBv_A4qE9g9ca5qxL5JrwCBCRtc2f9AhQCaWThzpPzBQEGbWV0aG9kBnN1Ym1pdAIGcGFyYW1z2wIBAiRAA1NTQwIJJGNvbnRyYWN0-QEBAiRAA1NNQwIDJGluJAMAACChE1h7ONUZg6hyDzwM1qqtf45FhgHKy8zWWgpN_sj2VwIEJHJ1br8BAQIkQANwYXkCBSR2YWxzrgECAABTAQIkQANUR04CAiRWChIBJICwr4yJoAEDAiRZIQLg1niES5tE941z3cyVO7ohtAZr4SAr11ZXFjMqRkXgzwkCJHTW8vHjpvar7ggDAiR4BMaIdRACAAFTAQIkQANUR04CAiRWChIBJICgt-yD_QADAiRZIQKYkUOPyywdDJ6G8OZ5eMLBKhvMhr4O3nuxfUiq1sO3BAkCJHSO6PTjpvar7ggDAiR4BPSQmA0CBiRzaWduc0QDAABAZRhWEMrAzAVqBJKa-pQIMf0O5PqDOLd62vzka6Z_MYaZq5rk39M47EdMeycnTNfGUot7Z1HdutgrNvcHme2KnAMFJHNpZ25AhgGz68Pq9LWPcnQPKeumtLYh0mGnnNsBk764abVvBYGthZDOYebP7zyz95wf-e2Kc7XqKOw3delXWcMwWXTEjA=='));

    test('Hibon adds values of all supported standard types', () {

      hibon.create();

      /// Add string.
      const addStringKey = 'addStringKey';
      expect(() => hibon.addString(addStringKey, 'value'), returnsNormally);
      expect(hibon.hasMemberByKey(addStringKey), isTrue);

      /// Add bool.
      const addBoolKey = 'addBoolKey';
      expect(() => hibon.addBool(addBoolKey, true), returnsNormally);
      expect(hibon.hasMemberByKey(addBoolKey), isTrue);

      /// Add int32.
      const addInt32Key = 'addInt32Key';
      expect(() => hibon.addInt<Int32>(addInt32Key, 10), returnsNormally);
      expect(hibon.hasMemberByKey(addInt32Key), isTrue);

      /// Add int64.
      const addInt64Key = 'addInt64Key';
      expect(() => hibon.addInt<Int64>(addInt64Key, 9223372036854775807), returnsNormally);
      expect(hibon.hasMemberByKey(addInt64Key), isTrue);

      /// Add uint32.
      const addUint32Key = 'addUint32Key';
      expect(() => hibon.addInt<Uint32>(addUint32Key, -10), returnsNormally);
      expect(hibon.hasMemberByKey(addUint32Key), isTrue);

      /// Add uint64.
      const addUint64Key = 'addUint64Key';
      expect(() => hibon.addInt<Uint64>(addUint64Key, -9223372036854775808), returnsNormally);
      expect(hibon.hasMemberByKey(addUint64Key), isTrue);

      /// Add float.
      const addFloatKey = 'addFloatKey';
      expect(() => hibon.addFloat<Float>(addFloatKey, 123.456), returnsNormally);
      expect(hibon.hasMemberByKey(addFloatKey), isTrue);

      /// Add double.
      const addDoubleKey = 'addDoubleKey';
      expect(() => hibon.addFloat<Double>(addDoubleKey, 123.456), returnsNormally);
      expect(hibon.hasMemberByKey(addDoubleKey), isTrue);

      /// Add time.
      const addTimeKey = 'addTimeKey';
      expect(() => hibon.addTime(addTimeKey, 638578428038904150), returnsNormally);
      expect(hibon.hasMemberByKey(addTimeKey), isTrue);

      /// Add bigint.
      const addBigIntKey = 'addBigIntKey';
      expect(() => hibon.addBigint(addBigIntKey, BigInt.from(9223372036854775807)), returnsNormally);
      expect(hibon.hasMemberByKey(addBigIntKey), isTrue);
    });

    test('Hibon adds, deletes values of all supported custom types', () {
      /// Hibon test.
      const nestedHibonKey = 'nestedHibonKey';
      final Hibon nestedHibon = Hibon(hibonFfi, errorMessage, pointerManager);
      nestedHibon.create();
      nestedHibon.addString(nestedHibonKey, 'value');

      const array = [1, 2, 3];

      /// By key.
      const docBuffKey = 'docBuffKey';
      const hibonKey = 'hibonKey';
      const arrayKey = 'arrayKey';

      expect(() => hibon.addDocumentBufferByKey(docBuffKey, hibonBuffer), returnsNormally);
      expect(() => hibon.addHibonByKey(hibonKey, nestedHibon), returnsNormally);
      expect(() => hibon.addArrayByKey(arrayKey, Uint8List.fromList(array)), returnsNormally);

      expect(hibon.hasMemberByKey(docBuffKey), isTrue);
      expect(hibon.hasMemberByKey(hibonKey), isTrue);
      expect(hibon.hasMemberByKey(arrayKey), isTrue);

      expect(() => hibon.removeByKey(docBuffKey), returnsNormally);
      expect(() => hibon.removeByKey(hibonKey), returnsNormally);
      expect(() => hibon.removeByKey(arrayKey), returnsNormally);

      expect(hibon.hasMemberByKey(docBuffKey), isFalse);
      expect(hibon.hasMemberByKey(hibonKey), isFalse);
      expect(hibon.hasMemberByKey(arrayKey), isFalse);

      /// By index.
      const docBuffIndex = 0;
      const hibonIndex = 1;
      const arrayIndex = 2;

      expect(() => hibon.addDocumentBufferByIndex(docBuffIndex, hibonBuffer), returnsNormally);
      expect(() => hibon.addHibonByIndex(hibonIndex, nestedHibon), returnsNormally);
      expect(() => hibon.addArrayByIndex(arrayIndex, Uint8List.fromList(array)), returnsNormally);

      expect(hibon.hasMemberByIndex(docBuffIndex), isTrue);
      expect(hibon.hasMemberByIndex(hibonIndex), isTrue);
      expect(hibon.hasMemberByIndex(arrayIndex), isTrue);

      expect(() => hibon.removeByIndex(docBuffIndex), returnsNormally);
      expect(() => hibon.removeByIndex(hibonIndex), returnsNormally);
      expect(() => hibon.removeByIndex(arrayIndex), returnsNormally);

      expect(hibon.hasMemberByIndex(docBuffIndex), isFalse);
      expect(hibon.hasMemberByIndex(hibonIndex), isFalse);
      expect(hibon.hasMemberByIndex(arrayIndex), isFalse);
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
