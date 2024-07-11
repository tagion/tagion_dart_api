import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tagion_dart_api/pointer_manager_interface.dart';
import 'package:tagion_dart_api/pointer_manager.dart';

class MockAllocator extends Mock implements Allocator {}

void main() {
  group('PointerManager', () {
    late IPointerManager pointerManager;
    late MockAllocator mockAllocator;

    setUp(() {
      pointerManager = const PointerManager();
      mockAllocator = MockAllocator();
    });

    test('allocate allocates memory correctly', () {
      final expectedPointer = malloc<Uint8>(10).cast<Uint8>();
      when(() => mockAllocator<Uint8>(10)).thenReturn(expectedPointer);

      final result = pointerManager.allocate<Uint8>(10, allocator: mockAllocator);

      expect(result, expectedPointer);
      verify(() => mockAllocator<Uint8>(10)).called(1);
      malloc.free(expectedPointer);
    });

    test('zeroOutPointer sets all bytes to zero', () {
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

    test('free deallocates memory correctly', () {
      final pointer = malloc<Uint8>(10).cast<Uint8>();
      when(() => mockAllocator.free(pointer)).thenReturn(null);

      pointerManager.free(pointer, allocator: mockAllocator);

      verify(() => mockAllocator.free(pointer)).called(1);
    });

    test('zeroOutAndFree zeroes out and then frees memory', () {
      final pointer = malloc<Uint8>(10).cast<Uint8>();
      for (var i = 0; i < 10; i++) {
        pointer[i] = 1;
      }
      when(() => mockAllocator.free(pointer)).thenReturn(null);

      pointerManager.zeroOutAndFree(pointer, 10, allocator: mockAllocator);

      for (var i = 0; i < 10; i++) {
        expect(pointer[i], 0);
      }
      verify(() => mockAllocator.free(pointer)).called(1);
    });
  });
}
