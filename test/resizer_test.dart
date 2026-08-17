import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:picstools/features/resizer/services/image_resizer_service.dart';
import 'package:picstools/features/resizer/bloc/resizer_bloc.dart';
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

  group('ResizerBloc Tests', () {
    late File testJpgFile1;
    late File testJpgFile2;

    setUp(() async {
      final tempDir = Directory.systemTemp;
      final img1 = img.Image(width: 800, height: 600);
      testJpgFile1 = File('${tempDir.path}/resizer_test_1.jpg');
      await testJpgFile1.writeAsBytes(img.encodeJpg(img1));

      final img2 = img.Image(width: 400, height: 300);
      testJpgFile2 = File('${tempDir.path}/resizer_test_2.jpg');
      await testJpgFile2.writeAsBytes(img.encodeJpg(img2));
    });

    tearDown(() async {
      if (await testJpgFile1.exists()) await testJpgFile1.delete();
      if (await testJpgFile2.exists()) await testJpgFile2.delete();
    });

    test('RemoveResizeImageEvent removes an image and updates state correctly', () async {
      final resizerService = ImageResizerService();
      final bloc = ResizerBloc(
        resizerService: resizerService,
        historyService: _MockHistoryService(),
      );

      bloc.add(SelectResizeImagesEvent([testJpgFile1, testJpgFile2]));
      await expectLater(
        bloc.stream,
        emits(isA<ResizerConfiguredState>().having(
          (s) => s.files.length,
          'files length',
          2,
        )),
      );

      bloc.add(const RemoveResizeImageEvent(0));
      await expectLater(
        bloc.stream,
        emits(isA<ResizerConfiguredState>().having(
          (s) => s.files.length,
          'files length',
          1,
        )),
      );

      bloc.add(const RemoveResizeImageEvent(0));
      await expectLater(
        bloc.stream,
        emits(isA<ResizerInitialState>()),
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
