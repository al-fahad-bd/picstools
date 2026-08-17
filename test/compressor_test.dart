import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:picstools/features/compressor/services/image_compressor_service.dart';
import 'package:picstools/features/compressor/bloc/compressor_bloc.dart';
import 'package:picstools/core/services/history_service.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = MockPathProviderPlatform();

  group('ImageCompressorService Tests', () {
    late File testJpgFile;
    late File testPngFile;

    setUp(() async {
      final tempDir = Directory.systemTemp;

      // Create a rich synthetic JPG
      final testJpgImg = img.Image(width: 800, height: 600);
      for (var y = 0; y < 600; y++) {
        for (var x = 0; x < 800; x++) {
          testJpgImg.setPixelRgb(x, y, (x * 255) ~/ 800, (y * 255) ~/ 600, ((x + y) * 255) ~/ 1400);
        }
      }
      final jpgBytes = img.encodeJpg(testJpgImg, quality: 75);
      testJpgFile = File('${tempDir.path}/test_image.jpg');
      await testJpgFile.writeAsBytes(jpgBytes);

      // Create a synthetic PNG
      final pngBytes = img.encodePng(testJpgImg);
      testPngFile = File('${tempDir.path}/test_image.png');
      await testPngFile.writeAsBytes(pngBytes);
    });

    tearDown(() async {
      if (await testJpgFile.exists()) await testJpgFile.delete();
      if (await testPngFile.exists()) await testPngFile.delete();
    });

    test('100% Quality does NOT produce an image larger than original', () async {
      final compressor = ImageCompressorService();
      final result = await compressor.compressImage(
        imageFile: testJpgFile,
        quality: 100,
      );

      expect(result.compressedSizeBytes, lessThanOrEqualTo(result.originalSizeBytes));
      expect(await result.compressedFile.exists(), true);
    });

    test('Target size constraint is respected', () async {
      final compressor = ImageCompressorService();
      const targetSize = 25 * 1024; // 25 KB
      final result = await compressor.compressImage(
        imageFile: testJpgFile,
        quality: 80,
        targetSizeBytes: targetSize,
      );

      expect(result.compressedSizeBytes, lessThanOrEqualTo(targetSize));
    });

    test('PNG compression does not increase file size', () async {
      final compressor = ImageCompressorService();
      final result = await compressor.compressImage(
        imageFile: testPngFile,
        quality: 100,
      );

      expect(result.compressedSizeBytes, lessThanOrEqualTo(result.originalSizeBytes));
    });
  });

  group('CompressorBloc Tests', () {
    late File testJpgFile;
    late File testPngFile;

    setUp(() async {
      final tempDir = Directory.systemTemp;
      final testImg = img.Image(width: 100, height: 100);
      testJpgFile = File('${tempDir.path}/bloc_test_image.jpg');
      await testJpgFile.writeAsBytes(img.encodeJpg(testImg));

      testPngFile = File('${tempDir.path}/bloc_test_image.png');
      await testPngFile.writeAsBytes(img.encodePng(testImg));
    });

    tearDown(() async {
      if (await testJpgFile.exists()) await testJpgFile.delete();
      if (await testPngFile.exists()) await testPngFile.delete();
    });

    test('RemoveImageEvent removes an image and updates state correctly', () async {
      final compressorService = ImageCompressorService();
      final bloc = CompressorBloc(
        compressorService: compressorService,
        historyService: _MockHistoryService(),
      );

      bloc.add(SelectImagesEvent([testJpgFile, testPngFile]));
      await expectLater(
        bloc.stream,
        emits(isA<CompressorImagesSelectedState>().having(
          (s) => s.files.length,
          'files length',
          2,
        )),
      );

      bloc.add(const RemoveImageEvent(0));
      await expectLater(
        bloc.stream,
        emits(isA<CompressorImagesSelectedState>().having(
          (s) => s.files.length,
          'files length',
          1,
        )),
      );

      bloc.add(const RemoveImageEvent(0));
      await expectLater(
        bloc.stream,
        emits(isA<CompressorInitialState>()),
      );

      await bloc.close();
    });
  });
}

class _MockHistoryService implements HistoryService {
  @override
  Stream<List<HistoryItem>> get historyStream => const Stream.empty();

  @override
  Future<void> addHistoryItem(HistoryItem item) async {}

  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> deleteHistoryItem(String id) async {}

  @override
  Future<List<HistoryItem>> getHistory() async => [];
}
