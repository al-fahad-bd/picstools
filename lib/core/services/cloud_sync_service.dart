import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'history_service.dart';
import 'storage/r2_storage_service.dart';

class SyncStatus {
  final int localCount;
  final int syncedCount;
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  const SyncStatus({
    this.localCount = 0,
    this.syncedCount = 0,
    this.isSyncing = false,
    this.lastSyncedAt,
    this.errorMessage,
  });

  bool get isFullySynced => localCount > 0 && localCount == syncedCount;
  int get pendingCount => (localCount - syncedCount).clamp(0, localCount);

  SyncStatus copyWith({
    int? localCount,
    int? syncedCount,
    bool? isSyncing,
    DateTime? lastSyncedAt,
    String? errorMessage,
  }) {
    return SyncStatus(
      localCount: localCount ?? this.localCount,
      syncedCount: syncedCount ?? this.syncedCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage,
    );
  }
}

class SyncResult {
  final bool success;
  final int uploadedCount;
  final int restoredCount;
  final String? errorMessage;

  const SyncResult({
    required this.success,
    this.uploadedCount = 0,
    this.restoredCount = 0,
    this.errorMessage,
  });
}

abstract class CloudSyncService {
  Stream<SyncStatus> get statusStream;
  SyncStatus get currentStatus;
  Future<void> refreshStatus();
  Future<SyncResult> syncNow();
}

class CloudSyncServiceImpl implements CloudSyncService {
  static const String _lastSyncedKey = 'picstools_last_cloud_sync';

  final AuthService authService;
  final HistoryService historyService;
  final R2StorageService r2Service;
  final FirebaseFirestore? firestore;
  final SharedPreferences prefs;

  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = const SyncStatus();
  StreamSubscription<List<HistoryItem>>? _historySub;
  StreamSubscription<String?>? _authSub;

  CloudSyncServiceImpl({
    required this.authService,
    required this.historyService,
    required this.r2Service,
    required this.prefs,
    this.firestore,
  }) {
    _loadLastSyncTime();
    _historySub = historyService.historyStream.listen((_) {
      refreshStatus();
    });
    _authSub = authService.authStateChanges.listen((_) {
      refreshStatus();
    });
    refreshStatus();
  }

  void _loadLastSyncTime() {
    final raw = prefs.getString(_lastSyncedKey);
    if (raw != null) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        _currentStatus = _currentStatus.copyWith(lastSyncedAt: parsed);
        _statusController.add(_currentStatus);
      }
    }
  }

  @override
  Stream<SyncStatus> get statusStream => _statusController.stream;

  @override
  SyncStatus get currentStatus => _currentStatus;

  @override
  Future<void> refreshStatus() async {
    try {
      final items = await historyService.getHistory();
      final localTotal = items.length;
      final syncedTotal = items.where((i) => i.isSynced).length;

      _currentStatus = _currentStatus.copyWith(
        localCount: localTotal,
        syncedCount: syncedTotal,
      );
      _statusController.add(_currentStatus);
    } catch (e) {
      debugPrint('⚠️ [CloudSyncService] refreshStatus error: $e');
    }
  }

  FirebaseFirestore? _resolveFirestore() {
    if (firestore != null) return firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('⚠️ [CloudSync] FirebaseFirestore not available: $e');
      return null;
    }
  }

  @override
  Future<SyncResult> syncNow() async {
    final uid = authService.currentUserId;
    final isSignedIn = authService.isSignedIn && !authService.isAnonymous;

    if (!isSignedIn || uid == null) {
      const msg = 'Please sign in to your account to back up history.';
      _currentStatus = _currentStatus.copyWith(isSyncing: false, errorMessage: msg);
      _statusController.add(_currentStatus);
      return const SyncResult(success: false, errorMessage: msg);
    }

    _currentStatus = _currentStatus.copyWith(isSyncing: true, errorMessage: null);
    _statusController.add(_currentStatus);

    int uploaded = 0;
    int restored = 0;

    try {
      final db = _resolveFirestore();
      final historyCollection =
          db?.collection('users').doc(uid).collection('history');

      // 1. Upload unsynced local items to Cloudflare R2 + Firestore
      final localItems = await historyService.getHistory();
      for (final item in localItems) {
        if (!item.isSynced) {
          final file = File(item.processedPath);
          if (await file.exists()) {
            final ext = p.extension(item.processedPath).isNotEmpty
                ? p.extension(item.processedPath)
                : '.png';
            final r2Key = 'users/$uid/history/${item.id}$ext';

            debugPrint('☁️ [CloudSync] Uploading to R2: $r2Key');
            final publicUrl = await r2Service.uploadFile(
              objectKey: r2Key,
              file: file,
            );

            if (publicUrl != null) {
              final updatedItem = item.copyWith(
                cloudProcessedUrl: publicUrl,
                cloudR2Key: r2Key,
              );

              // Save metadata to Firestore if available
              if (historyCollection != null) {
                await historyCollection.doc(item.id).set({
                  'id': updatedItem.id,
                  'toolName': updatedItem.toolName,
                  'timestamp': updatedItem.timestamp.toIso8601String(),
                  'originalSizeBytes': updatedItem.originalSizeBytes,
                  'processedSizeBytes': updatedItem.processedSizeBytes,
                  'cloudProcessedUrl': publicUrl,
                  'cloudR2Key': r2Key,
                  'syncedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
              }

              // Update local state
              await historyService.updateHistoryItem(updatedItem);
              uploaded++;
            }
          }
        }
      }

      // 2. Fetch remote items from Firestore to restore any items missing locally
      if (historyCollection != null) {
        try {
          final remoteSnapshot = await historyCollection.get();
          final localIds = localItems.map((i) => i.id).toSet();

          for (final doc in remoteSnapshot.docs) {
            final data = doc.data();
            final remoteId = data['id'] as String? ?? doc.id;

            if (!localIds.contains(remoteId)) {
              final cloudUrl = data['cloudProcessedUrl'] as String?;
              final cloudKey = data['cloudR2Key'] as String?;
              final toolName = data['toolName'] as String? ?? 'PicsTools Image';
              final timestampStr = data['timestamp'] as String?;
              final timestamp = timestampStr != null
                  ? DateTime.tryParse(timestampStr) ?? DateTime.now()
                  : DateTime.now();

              final docsDir = await getApplicationDocumentsDirectory();
              final historyDir = Directory(p.join(docsDir.path, 'history_files'));
              if (!await historyDir.exists()) {
                await historyDir.create(recursive: true);
              }

              final ext = cloudKey != null ? p.extension(cloudKey) : '.png';
              final localFilePath =
                  p.join(historyDir.path, 'hist_$remoteId$ext');

              // Add item to local history
              final restoredItem = HistoryItem(
                id: remoteId,
                toolName: toolName,
                originalPath: localFilePath,
                processedPath: localFilePath,
                originalSizeBytes: (data['originalSizeBytes'] as num?)?.toInt() ?? 0,
                processedSizeBytes: (data['processedSizeBytes'] as num?)?.toInt() ?? 0,
                timestamp: timestamp,
                cloudProcessedUrl: cloudUrl,
                cloudR2Key: cloudKey,
              );

              await historyService.addHistoryItem(restoredItem);
              restored++;
            }
          }
        } catch (e) {
          debugPrint('⚠️ [CloudSync] Could not check remote items: $e');
        }
      }

      final now = DateTime.now();
      await prefs.setString(_lastSyncedKey, now.toIso8601String());

      final updatedLocalList = await historyService.getHistory();
      _currentStatus = SyncStatus(
        localCount: updatedLocalList.length,
        syncedCount: updatedLocalList.where((i) => i.isSynced).length,
        isSyncing: false,
        lastSyncedAt: now,
      );
      _statusController.add(_currentStatus);

      return SyncResult(
        success: true,
        uploadedCount: uploaded,
        restoredCount: restored,
      );
    } catch (e) {
      debugPrint('❌ [CloudSync] syncNow error: $e');
      final errorStr = 'Sync failed: $e';
      _currentStatus = _currentStatus.copyWith(
        isSyncing: false,
        errorMessage: errorStr,
      );
      _statusController.add(_currentStatus);
      return SyncResult(success: false, errorMessage: errorStr);
    }
  }

  void dispose() {
    _historySub?.cancel();
    _authSub?.cancel();
    _statusController.close();
  }
}

class MockCloudSyncService implements CloudSyncService {
  SyncStatus _status = const SyncStatus();
  final _controller = StreamController<SyncStatus>.broadcast();

  @override
  SyncStatus get currentStatus => _status;

  @override
  Stream<SyncStatus> get statusStream => _controller.stream;

  @override
  Future<void> refreshStatus() async {}

  @override
  Future<SyncResult> syncNow() async {
    _status = _status.copyWith(
      syncedCount: _status.localCount,
      lastSyncedAt: DateTime.now(),
    );
    _controller.add(_status);
    return const SyncResult(success: true, uploadedCount: 1);
  }
}
