import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager.dart';
import 'package:tagion_dart_api/pointer_manager/pointer_manager_interface.dart';

class MockAllocator extends Mock implements Allocator {}

void main() {
  group('PointerManager Unit.', () {
    late IPointerManager pointerManager;
    late MockAllocator mockAllocator;

    setUp(() {
      pointerManager = const PointerManager();
      mockAllocator = MockAllocator();
    });

    test('Allocate allocates memory correctly', () {
      final expectedPointer = malloc<Uint8>(10).cast<Uint8>();
      when(() => mockAllocator<Uint8>(10)).thenReturn(expectedPointer);

      final result = pointerManager.allocate<Uint8>(10, mockAllocator);

      expect(result, expectedPointer);
      verify(() => mockAllocator<Uint8>(10)).called(1);
      malloc.free(expectedPointer);
    });

    test('ZeroOutPointer sets all bytes to zero', () {
      final pointer = malloc<Uint8>(10).cast<Uint8>();
      for (var i = 0; i < 10; i++) {
        pointer[i] = 1;
      }

      pointerManager.zeroOutPointer(pointer, 10);

      for (var i = 0; i < 10; i++) {
        expect(pointer[i], 0);
      }
      malloc.free(pointer);
    });

    test('Free deallocates memory correctly', () {
      final pointer = malloc<Uint8>(10).cast<Uint8>();
      when(() => mockAllocator.free(pointer)).thenReturn(null);

      pointerManager.free(pointer, mockAllocator);

      verify(() => mockAllocator.free(pointer)).called(1);
    });

    test('Free all deallocates all provided pointers correctly', () {
      final pointerA = malloc<Uint8>(10).cast<Uint8>();
      final pointerB = malloc<Uint8>(10).cast<Uint8>();
      final pointerC = malloc<Uint8>(10).cast<Uint8>();

      when(() => mockAllocator.free(pointerA)).thenReturn(null);
      when(() => mockAllocator.free(pointerB)).thenReturn(null);
      when(() => mockAllocator.free(pointerC)).thenReturn(null);

      pointerManager.freeAll([pointerA, pointerB, pointerC], mockAllocator);

      verify(() => mockAllocator.free(pointerA)).called(1);
      verify(() => mockAllocator.free(pointerB)).called(1);
      verify(() => mockAllocator.free(pointerC)).called(1);
    });

    test('ZeroOutAndFree zeroes out and then frees memory', () {
      final int typeSize = sizeOf<Float>();
      final Pointer<Uint8> pointer = malloc<Float>(typeSize).cast<Uint8>();
      for (var i = 0; i < typeSize; i++) {
        pointer[i] = 1;
      }
      when(() => mockAllocator.free(pointer)).thenReturn(null);

      pointerManager.zeroOutAndFree(pointer, typeSize, mockAllocator);

      for (var i = 0; i < typeSize; i++) {
        expect(pointer[i], 0);
      }
      verify(() => mockAllocator.free(pointer)).called(1);
    });

    test('fills pointer with values from list', () {
      final Uint8List list = Uint8List.fromList([1, 2, 3]);
      final Pointer<Uint8> pointer = malloc.allocate(list.length);
      pointerManager.uint8ListToPointer(pointer, list);
      expect(pointer[0], 1);
      expect(pointer[1], 2);
      expect(pointer[2], 3);
      malloc.free(pointer);
    });

    test('fills pointer with string', () {
      const String data = 'hello';
      final Pointer<Uint8> pointer = malloc.allocate(data.length);
      pointerManager.stringToPointer(pointer, data);
      expect(pointer[0], utf8.encode(data[0])[0]);
      expect(pointer[1], utf8.encode(data[1])[0]);
      expect(pointer[2], utf8.encode(data[2])[0]);
      expect(pointer[3], utf8.encode(data[3])[0]);
      expect(pointer[4], utf8.encode(data[4])[0]);
      malloc.free(pointer);
    });
  });
}
