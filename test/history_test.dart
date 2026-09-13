import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:picstools/core/services/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempTestDir;
  late Directory docsTestDir;
  late SharedPreferences prefs;
  late HistoryServiceImpl historyService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    tempTestDir = await Directory.systemTemp.createTemp('picstools_temp_test_');
    docsTestDir = await Directory.systemTemp.createTemp('picstools_docs_test_');

    historyService = HistoryServiceImpl(
      prefs,
      docsDirProvider: () async => docsTestDir,
    );
  });

  tearDown(() async {
    try {
      if (await tempTestDir.exists()) {
        await tempTestDir.delete(recursive: true);
      }
      if (await docsTestDir.exists()) {
        await docsTestDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  test('addHistoryItem copies temp file to permanent documents directory', () async {
    // 1. Create a dummy file in temp dir
    final dummyTempFile = File('${tempTestDir.path}/temp_result.png');
    await dummyTempFile.writeAsString('fake_png_data');

    final item = HistoryItem(
      id: 'item_101',
      toolName: 'Remove BG',
      originalPath: '${tempTestDir.path}/orig.jpg',
      processedPath: dummyTempFile.path,
      originalSizeBytes: 100,
      processedSizeBytes: 50,
      timestamp: DateTime.now(),
    );

    // 2. Add to history
    await historyService.addHistoryItem(item);

    // 3. Verify history item was saved with new path in docs dir
    final history = await historyService.getHistory();
    expect(history.length, equals(1));
    expect(history.first.id, equals('item_101'));
    expect(history.first.processedPath, isNot(equals(dummyTempFile.path)));
    expect(history.first.processedPath, contains('history_files'));
    expect(history.first.processedPath, contains('hist_item_101.png'));

    // 4. Verify file exists in permanent storage
    final permanentFile = File(history.first.processedPath);
    expect(await permanentFile.exists(), isTrue);
    expect(await permanentFile.readAsString(), equals('fake_png_data'));
  });

  test('deleteHistoryItem removes both item and persistent file', () async {
    final dummyTempFile = File('${tempTestDir.path}/to_delete.png');
    await dummyTempFile.writeAsString('delete_me');

    final item = HistoryItem(
      id: 'del_1',
      toolName: 'Compress',
      originalPath: 'dummy_orig',
      processedPath: dummyTempFile.path,
      originalSizeBytes: 200,
      processedSizeBytes: 100,
      timestamp: DateTime.now(),
    );

    await historyService.addHistoryItem(item);
    var history = await historyService.getHistory();
    expect(history.length, equals(1));

    final persistedPath = history.first.processedPath;
    expect(await File(persistedPath).exists(), isTrue);

    // Delete item
    await historyService.deleteHistoryItem('del_1');

    history = await historyService.getHistory();
    expect(history.isEmpty, isTrue);
    expect(await File(persistedPath).exists(), isFalse);
  });

  test('clearHistory removes all items and clears persistent history directory', () async {
    final file1 = File('${tempTestDir.path}/f1.png');
    await file1.writeAsString('1');
    final file2 = File('${tempTestDir.path}/f2.png');
    await file2.writeAsString('2');

    await historyService.addHistoryItem(HistoryItem(
      id: 'item_1',
      toolName: 'Tool 1',
      originalPath: 'orig1',
      processedPath: file1.path,
      originalSizeBytes: 10,
      processedSizeBytes: 5,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ));

    await historyService.addHistoryItem(HistoryItem(
      id: 'item_2',
      toolName: 'Tool 2',
      originalPath: 'orig2',
      processedPath: file2.path,
      originalSizeBytes: 20,
      processedSizeBytes: 10,
      timestamp: DateTime.now(),
    ));

    expect((await historyService.getHistory()).length, equals(2));

    await historyService.clearHistory();

    final clearedHistory = await historyService.getHistory();
    expect(clearedHistory.isEmpty, isTrue);

    final historyDir = Directory('${docsTestDir.path}/history_files');
    expect(await historyDir.exists(), isFalse);
  });

  test('getHistory automatically migrates un-migrated existing files', () async {
    final oldTempFile = File('${tempTestDir.path}/unmigrated.png');
    await oldTempFile.writeAsString('old_cache_content');

    // Simulate pre-existing record in SharedPreferences pointing to temp file
    final rawItem = HistoryItem(
      id: 'legacy_item',
      toolName: 'Remove BG',
      originalPath: 'orig',
      processedPath: oldTempFile.path,
      originalSizeBytes: 500,
      processedSizeBytes: 250,
      timestamp: DateTime.now(),
    );
    await prefs.setStringList('picstools_history', [
      jsonEncode(rawItem.toJson()),
    ]);

    // Calling getHistory should detect the file and copy it into permanent storage
    final history = await historyService.getHistory();
    expect(history.length, equals(1));
    expect(history.first.processedPath, isNot(equals(oldTempFile.path)));
    expect(history.first.processedPath, contains('history_files'));

    final migratedFile = File(history.first.processedPath);
    expect(await migratedFile.exists(), isTrue);
    expect(await migratedFile.readAsString(), equals('old_cache_content'));
  });
}
