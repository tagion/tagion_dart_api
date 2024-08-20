import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagion_dart_api/basic/ffi/basic_ffi.dart';
import 'package:tagion_dart_api/crypto/crypto.dart';
import 'package:tagion_dart_api/crypto/ffi/crypto_ffi.dart';
import 'package:tagion_dart_api/document/document.dart';
import 'package:tagion_dart_api/document/ffi/document_ffi.dart';
import 'package:tagion_dart_api/enums/document_error_code.dart';
import 'package:tagion_dart_api/error_message/error_message.dart';
import 'package:tagion_dart_api/error_message/error_message_interface.dart';
import 'package:tagion_dart_api/error_message/ffi/error_message_ffi.dart';
import 'package:tagion_dart_api/hirpc/hirpc.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';
import 'package:tagion_dart_api/utils/ffi_library_util.dart';

void main() {
  final DynamicLibrary dyLib = FFILibraryUtil.load();
  BasicFfi basicFfi = BasicFfi(dyLib);
  setUpAll(() {
    basicFfi.start_rt();
  });

  hirpcIntegrationTest(dyLib);

  tearDownAll(() {
    basicFfi.stop_rt();
  });
}

void hirpcIntegrationTest(DynamicLibrary dyLib) {
  group('HiRPC-CryptoFfi-Binary Integration.', () {
    final CryptoFfi cryptoFfi = CryptoFfi(dyLib);
    const IPointerManager pointerManager = PointerManager();
    final IErrorMessage errorMessage = ErrorMessage(ErrorMessageFfi(dyLib), pointerManager);

    final Crypto crypto = Crypto(cryptoFfi, pointerManager, errorMessage);
    final TagionHiRPC hiRPC = TagionHiRPC(cryptoFfi, pointerManager, errorMessage);

    const String passphrase = 'passphrase';
    const String pinCode = 'pinCode';
    const String salt = 'salt';

    test('creates a signed request', () {
      const String testMethod = 'METHOD';

      Pointer<SecureNet> secureNetPtr = pointerManager.allocate<SecureNet>();

      crypto.generateKeypair(passphrase, pinCode, salt, secureNetPtr);
      Uint8List signedRequest = hiRPC.createSignedRequest(
          testMethod, secureNetPtr, Uint8List.fromList([0, 1, 2, 3]), Uint8List.fromList([0, 1, 2, 3]));
      expect(signedRequest, isNotEmpty);
      Document hibonDoc = Document(DocumentFfi(dyLib), pointerManager, errorMessage, signedRequest);
      expect(hibonDoc.validate(), DocumentErrorCode.none);
    });

    test('creates a request', () {
      const String testMethod = 'METHOD';

      Pointer<SecureNet> secureNetPtr = pointerManager.allocate<SecureNet>();

      crypto.generateKeypair(passphrase, pinCode, salt, secureNetPtr);
      Uint8List request = hiRPC.createRequest(testMethod, Uint8List.fromList([0, 1, 2, 3]));
      expect(request, isNotEmpty);
      Document hibonDoc = Document(DocumentFfi(dyLib), pointerManager, errorMessage, request);
      expect(hibonDoc.validate(), DocumentErrorCode.none);
    });
  });
}
