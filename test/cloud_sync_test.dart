import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:picstools/core/services/auth_service.dart';
import 'package:picstools/core/services/cloud_sync_service.dart';
import 'package:picstools/core/services/history_service.dart';
import 'package:picstools/core/services/storage/r2_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestHistoryService implements HistoryService {
  final List<HistoryItem> items = [];
  final _controller = StreamController<List<HistoryItem>>.broadcast();

  @override
  Stream<List<HistoryItem>> get historyStream => _controller.stream;

  @override
  Future<void> addHistoryItem(HistoryItem item) async {
    items.add(item);
    _controller.add(List.unmodifiable(items));
  }

  @override
  Future<void> clearHistory() async {
    items.clear();
    _controller.add(List.unmodifiable(items));
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    items.removeWhere((i) => i.id == id);
    _controller.add(List.unmodifiable(items));
  }

  @override
  Future<List<HistoryItem>> getHistory() async => List.unmodifiable(items);

  @override
  Future<void> updateHistoryItem(HistoryItem item) async {
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      items[idx] = item;
      _controller.add(List.unmodifiable(items));
    }
  }

  @override
  Future<void> resetSyncStatus() async {
    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(clearCloudSync: true);
    }
    _controller.add(List.unmodifiable(items));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late MockAuthServiceImpl mockAuth;
  late _TestHistoryService testHistory;
  late MockR2StorageServiceImpl mockR2;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockAuth = MockAuthServiceImpl();
    testHistory = _TestHistoryService();
    mockR2 = MockR2StorageServiceImpl();
  });

  group('SyncStatus model', () {
    test('computes isFullySynced and pendingCount correctly', () {
      const status1 = SyncStatus(localCount: 5, syncedCount: 3);
      expect(status1.isFullySynced, isFalse);
      expect(status1.pendingCount, equals(2));

      const status2 = SyncStatus(localCount: 5, syncedCount: 5);
      expect(status2.isFullySynced, isTrue);
      expect(status2.pendingCount, equals(0));

      const status3 = SyncStatus(localCount: 0, syncedCount: 0);
      expect(status3.isFullySynced, isFalse);
      expect(status3.pendingCount, equals(0));
    });
  });

  group('CloudSyncServiceImpl', () {
    test('refreshStatus emits accurate local and synced count', () async {
      final syncService = CloudSyncServiceImpl(
        authService: mockAuth,
        historyService: testHistory,
        r2Service: mockR2,
        prefs: prefs,
      );

      // Initially empty
      await syncService.refreshStatus();
      expect(syncService.currentStatus.localCount, equals(0));
      expect(syncService.currentStatus.syncedCount, equals(0));

      // Add 2 items (1 unsynced, 1 synced)
      final now = DateTime.now();
      await testHistory.addHistoryItem(HistoryItem(
        id: '1',
        toolName: 'Tool',
        originalPath: 'p1',
        processedPath: 'p1',
        originalSizeBytes: 10,
        processedSizeBytes: 5,
        timestamp: now,
      ));
      await testHistory.addHistoryItem(HistoryItem(
        id: '2',
        toolName: 'Tool',
        originalPath: 'p2',
        processedPath: 'p2',
        originalSizeBytes: 10,
        processedSizeBytes: 5,
        timestamp: now,
        cloudProcessedUrl: 'https://r2.dev/p2.png',
        cloudR2Key: 'users/123/history/2.png',
      ));

      await syncService.refreshStatus();
      expect(syncService.currentStatus.localCount, equals(2));
      expect(syncService.currentStatus.syncedCount, equals(1));
      expect(syncService.currentStatus.pendingCount, equals(1));
      expect(syncService.currentStatus.isFullySynced, isFalse);

      syncService.dispose();
    });

    test('syncNow blocks if user is not signed in', () async {
      final syncService = CloudSyncServiceImpl(
        authService: mockAuth,
        historyService: testHistory,
        r2Service: mockR2,
        prefs: prefs,
      );

      final result = await syncService.syncNow();
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('sign in'));
      expect(syncService.currentStatus.isSyncing, isFalse);

      syncService.dispose();
    });

    test('syncNow uploads unsynced items to R2 when signed in', () async {
      await mockAuth.signInWithEmailPassword('user@example.com', 'pass123');

      // Create a real temp file so File.exists() succeeds
      final tempDir = await Directory.systemTemp.createTemp('sync_test_');
      final tempFile = File('${tempDir.path}/test.png');
      await tempFile.writeAsString('image_bytes');

      await testHistory.addHistoryItem(HistoryItem(
        id: 'local_item_1',
        toolName: 'Compress',
        originalPath: tempFile.path,
        processedPath: tempFile.path,
        originalSizeBytes: 100,
        processedSizeBytes: 50,
        timestamp: DateTime.now(),
      ));

      final syncService = CloudSyncServiceImpl(
        authService: mockAuth,
        historyService: testHistory,
        r2Service: mockR2,
        prefs: prefs,
      );

      // Execute syncNow
      final result = await syncService.syncNow();
      expect(result.success, isTrue);
      expect(result.uploadedCount, equals(1));

      // Verify item was updated with cloud url in history
      final history = await testHistory.getHistory();
      expect(history.first.isSynced, isTrue);
      expect(history.first.cloudProcessedUrl, contains('history'));

      // Clean up
      syncService.dispose();
      await tempDir.delete(recursive: true);
    });
  });

  group('R2StorageService Mock', () {
    test('mock upload and delete work as expected', () async {
      final r2 = MockR2StorageServiceImpl();
      final url = await r2.uploadBytes(
        objectKey: 'users/123/history/test.png',
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'image/png',
      );

      expect(url, equals('https://mock.r2.dev/users/123/history/test.png'));

      final deleted = await r2.deleteFile('users/123/history/test.png');
      expect(deleted, isTrue);
    });
  });
}
