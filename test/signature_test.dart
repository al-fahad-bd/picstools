import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:picstools/features/signature/services/signature_service.dart';
import 'package:picstools/features/signature/bloc/signature_bloc.dart';
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

  group('SignatureService & SignatureBloc Tests', () {
    late File testPaperPhoto;

    setUp(() async {
      final tempDir = Directory.systemTemp;
      final image = img.Image(width: 400, height: 300);
      img.fill(image, color: img.ColorRgb8(240, 240, 240)); // Paper background

      // Draw a dark simulated signature stroke in the middle
      img.drawLine(
        image,
        x1: 100,
        y1: 150,
        x2: 300,
        y2: 150,
        color: img.ColorRgb8(10, 10, 40),
        thickness: 4,
      );

      testPaperPhoto = File('${tempDir.path}/test_paper_sig.jpg');
      await testPaperPhoto.writeAsBytes(img.encodeJpg(image));
    });

    tearDown(() async {
      if (await testPaperPhoto.exists()) await testPaperPhoto.delete();
    });

    test('scanPaperSignature extracts clean signature', () async {
      final service = SignatureService();
      final result = await service.scanPaperSignature(photoFile: testPaperPhoto);

      expect(result.transparentPngFile.existsSync(), isTrue);
      expect(result.solidBackgroundFile.existsSync(), isTrue);
      expect(result.widthPx, greaterThan(0));
      expect(result.heightPx, greaterThan(0));
    });

    test(
      'adjustSignature crops and rotates transparent signature with arbitrary angles properly',
      () async {
        final service = SignatureService();
        final initialResult = await service.scanPaperSignature(photoFile: testPaperPhoto);

        final adjustedResult = await service.adjustSignature(
          transparentPngFile: initialResult.transparentPngFile,
          cropXRatio: 0.1,
          cropYRatio: 0.1,
          cropWidthRatio: 0.8,
          cropHeightRatio: 0.8,
          rotationAngle: 12.5,
        );

        expect(adjustedResult.transparentPngFile.existsSync(), isTrue);
        expect(adjustedResult.solidBackgroundFile.existsSync(), isTrue);
        expect(adjustedResult.widthPx, greaterThan(0));
        expect(adjustedResult.heightPx, greaterThan(0));
      },
    );

    test(
      'SignatureBloc handles ScanPaperSignatureEvent and AdjustSignatureEvent with free angle',
      () async {
        final service = SignatureService();
        final bloc = SignatureBloc(
          signatureService: service,
          historyService: _MockHistoryService(),
        );

        bloc.add(ScanPaperSignatureEvent(
          photoFile: testPaperPhoto,
          cropXRatio: 0.1,
          cropYRatio: 0.1,
          cropWidthRatio: 0.8,
          cropHeightRatio: 0.8,
          rotationAngle: 15.0,
        ));
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<SignatureProcessingState>(),
            isA<SignatureSuccessState>(),
          ]),
        );

        bloc.add(
          const AdjustSignatureEvent(
            cropXRatio: 0.05,
            cropYRatio: 0.05,
            cropWidthRatio: 0.9,
            cropHeightRatio: 0.9,
            rotationAngle: -7.5,
          ),
        );

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<SignatureProcessingState>(),
            isA<SignatureSuccessState>(),
          ]),
        );

        await bloc.close();
      },
    );
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
