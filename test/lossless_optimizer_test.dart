import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:picstools/core/services/storage/lossless_optimizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LosslessImageOptimizer', () {
    test('optimizes PNG losslessly without altering pixels', () async {
      final image = img.Image(width: 150, height: 150, numChannels: 4);
      img.fill(image, color: img.ColorRgba8(0, 120, 250, 200));

      final originalPng = Uint8List.fromList(img.encodePng(image, level: 1));
      final optimizedPng = await LosslessImageOptimizer.optimize(
        bytes: originalPng,
        filePath: 'test.png',
      );

      // Must be smaller or equal
      expect(optimizedPng.length <= originalPng.length, isTrue);

      // Verify exact pixel fidelity
      final decoded = img.decodePng(optimizedPng);
      expect(decoded, isNotNull);
      expect(decoded!.width, equals(150));
      expect(decoded.height, equals(150));

      final pixel = decoded.getPixel(50, 50);
      expect(pixel.r, equals(0));
      expect(pixel.g, equals(120));
      expect(pixel.b, equals(250));
      expect(pixel.a, equals(200));
    });

    test('returns original bytes if already optimally compressed or unknown format', () async {
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = await LosslessImageOptimizer.optimize(
        bytes: dummyBytes,
        filePath: 'test.unknown',
      );

      expect(result, equals(dummyBytes));
    });
  });
}
