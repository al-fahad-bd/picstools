import 'package:flutter_test/flutter_test.dart';
import 'package:picstools/features/background_remover/data/models/ai_model_info_model.dart';
import 'package:picstools/features/background_remover/data/datasources/onnx_inference_datasource.dart';
import 'package:image/image.dart' as img;

void main() {
  group('AiModelInfoModel Tests', () {
    test('default model has correct properties', () {
      const model = AiModelInfoModel.defaultModel;
      expect(model.modelId, equals('u2netp'));
      expect(model.fileName, equals('u2netp.onnx'));
      expect(model.version, equals('1.0.0'));
      expect(model.isDownloaded, isFalse);
      expect(model.formattedExpectedSize, contains('MB'));
    });

    test('json serialization and deserialization roundtrip', () {
      const model = AiModelInfoModel(
        modelId: 'test-model',
        displayName: 'Test Model',
        version: '1.2.0',
        fileName: 'test.onnx',
        downloadUrl: 'https://example.com/test.onnx',
        expectedSizeBytes: 100000000,
        isDownloaded: true,
        actualSizeBytes: 99500000,
        sha256: 'abc123hash',
      );

      final json = model.toJson();
      final fromJson = AiModelInfoModel.fromJson(json);

      expect(fromJson.modelId, equals('test-model'));
      expect(fromJson.displayName, equals('Test Model'));
      expect(fromJson.version, equals('1.2.0'));
      expect(fromJson.fileName, equals('test.onnx'));
      expect(fromJson.downloadUrl, equals('https://example.com/test.onnx'));
      expect(fromJson.expectedSizeBytes, equals(100000000));
      expect(fromJson.actualSizeBytes, equals(99500000));
      expect(fromJson.sha256, equals('abc123hash'));
      expect(fromJson.isDownloaded, isTrue);
    });

    test(
      'copyWith returns AiModelInfoModel instance and preserves properties',
      () {
        final copy = AiModelInfoModel.defaultModel.copyWith(
          isDownloaded: true,
          actualSizeBytes: 4700000,
          localFilePath: '/path/to/model.onnx',
        );

        expect(copy, isA<AiModelInfoModel>());
        expect(copy.isDownloaded, isTrue);
        expect(copy.actualSizeBytes, equals(4700000));
        expect(copy.localFilePath, equals('/path/to/model.onnx'));
        expect(copy.modelId, equals(AiModelInfoModel.defaultModel.modelId));
      },
    );
  });

  group('U2NetModelAdapter Tests', () {
    final adapter = U2NetModelAdapter();

    test('has 320x320 resolution and ImageNet mean/std', () {
      expect(adapter.inputWidth, equals(320));
      expect(adapter.inputHeight, equals(320));
      expect(adapter.mean, equals([0.485, 0.456, 0.406]));
      expect(adapter.std, equals([0.229, 0.224, 0.225]));
    });

    test('preprocess produces correct float tensor shape', () {
      final testImage = img.Image(width: 100, height: 100);
      img.fill(testImage, color: img.ColorRgb8(255, 255, 255));

      final tensor = adapter.preprocess(testImage);
      // NCHW shape: 1 * 3 * 320 * 320 = 307200
      expect(tensor.length, equals(3 * 320 * 320));
    });

    test('postprocess normalizes min-max saliency map', () {
      final rawSaliency = [0.0, 10.0, 5.0, -10.0];
      final alphas = adapter.postprocess(rawSaliency);

      expect(alphas[0], closeTo(0.5, 0.001)); // (-10 to 10): (0 - -10)/20 = 0.5
      expect(alphas[1], closeTo(1.0, 0.001)); // 10 -> 1.0
      expect(alphas[2], closeTo(0.75, 0.001)); // 5 -> 0.75
      expect(alphas[3], closeTo(0.0, 0.001)); // -10 -> 0.0
    });
  });

  group('BiRefNetModelAdapter Tests', () {
    final adapter = BiRefNetModelAdapter();

    test('has 512x512 resolution and ImageNet mean/std', () {
      expect(adapter.inputWidth, equals(512));
      expect(adapter.inputHeight, equals(512));
      expect(adapter.mean, equals([0.485, 0.456, 0.406]));
      expect(adapter.std, equals([0.229, 0.224, 0.225]));
    });

    test('preprocess produces correct float tensor shape', () {
      final testImage = img.Image(width: 100, height: 100);
      img.fill(testImage, color: img.ColorRgb8(255, 255, 255));

      final tensor = adapter.preprocess(testImage);
      // NCHW shape: 1 * 3 * 512 * 512 = 786432
      expect(tensor.length, equals(3 * 512 * 512));
    });

    test('postprocess correctly applies sigmoid activation to logits', () {
      final rawLogits = [0.0, 10.0, -10.0, 2.0, -2.0];
      final alphas = adapter.postprocess(rawLogits);

      expect(alphas[0], closeTo(0.5, 0.001)); // sigmoid(0) = 0.5
      expect(alphas[1], closeTo(0.9999, 0.001)); // sigmoid(10) ~ 1.0
      expect(alphas[2], closeTo(0.00004, 0.0001)); // sigmoid(-10) ~ 0.0
      expect(alphas[3], greaterThan(0.8)); // sigmoid(2) ~ 0.88
      expect(alphas[4], lessThan(0.2)); // sigmoid(-2) ~ 0.12
    });

    test('postprocess handles nested multidimensional tensor output', () {
      final nestedOutput = [
        [
          [
            [0.0, 5.0],
            [-5.0, 2.0],
          ]
        ]
      ];
      final alphas = adapter.postprocess(nestedOutput);
      expect(alphas.length, equals(4));
      expect(alphas[0], closeTo(0.5, 0.001));
      expect(alphas[1], greaterThan(0.99));
      expect(alphas[2], lessThan(0.01));
      expect(alphas[3], greaterThan(0.85));
    });
  });
}
