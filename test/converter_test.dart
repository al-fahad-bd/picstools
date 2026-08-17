import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:picstools/features/converter/services/image_converter_service.dart';
import 'package:picstools/features/converter/bloc/converter_bloc.dart';
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

  group('ConverterBloc Tests', () {
    late File testJpgFile1;
    late File testJpgFile2;

    setUp(() async {
      final tempDir = Directory.systemTemp;
      final img1 = img.Image(width: 400, height: 300);
      testJpgFile1 = File('${tempDir.path}/converter_test_1.jpg');
      await testJpgFile1.writeAsBytes(img.encodeJpg(img1));

      final img2 = img.Image(width: 200, height: 150);
      testJpgFile2 = File('${tempDir.path}/converter_test_2.jpg');
      await testJpgFile2.writeAsBytes(img.encodeJpg(img2));
    });

    tearDown(() async {
      if (await testJpgFile1.exists()) await testJpgFile1.delete();
      if (await testJpgFile2.exists()) await testJpgFile2.delete();
    });

    test('RemoveConvertImageEvent removes an image and resets to initial when empty', () async {
      final converterService = ImageConverterService();
      final bloc = ConverterBloc(
        converterService: converterService,
        historyService: _MockHistoryService(),
      );

      bloc.add(SelectConvertImagesEvent([testJpgFile1, testJpgFile2]));
      await expectLater(
        bloc.stream,
        emits(isA<ConverterConfiguredState>().having(
          (s) => s.files.length,
          'files length',
          2,
        )),
      );

      bloc.add(const RemoveConvertImageEvent(0));
      await expectLater(
        bloc.stream,
        emits(isA<ConverterConfiguredState>().having(
          (s) => s.files.length,
          'files length',
          1,
        )),
      );

      bloc.add(const RemoveConvertImageEvent(0));
      await expectLater(
        bloc.stream,
        emits(isA<ConverterInitialState>()),
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
