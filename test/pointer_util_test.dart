import 'dart:ffi';

import 'package:tagion_dart_api/pointer_util.dart';
import 'package:test/test.dart';

void main() {
  group('PointerUtils', () {
    test('allocate should allocate Uint8 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Uint8>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate Int8 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Int8>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate Uint16 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Uint16>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate Int16 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Int16>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate Uint32 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Uint32>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate Int32 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Int32>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate Uint64 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Uint64>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate Int64 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Int64>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate Float memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Float>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate Double memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Double>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate IntPtr memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<IntPtr>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('allocate should allocate Char memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Char>(size);
      expect(pointer.address, isNot(0));
      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Uint8 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Uint8>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Int8 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Int8>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Uint16 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Uint16>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Int16 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Int16>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Uint32 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Uint32>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Int32 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Int32>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Uint64 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Uint64>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Int64 memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Int64>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Float memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Float>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Double memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Double>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out IntPtr memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<IntPtr>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });

    test('zeroOutPointer should zero out Char memory', () {
      const size = 10;
      final pointer = PointerUtil.allocate<Char>(size);

      for (var i = 0; i < size; i++) {
        pointer[i] = 42;
      }

      PointerUtil.zeroOutPointer(pointer, size);

      for (var i = 0; i < size; i++) {
        expect(pointer[i], equals(0));
      }

      PointerUtil.free(pointer);
    });
  });
}
