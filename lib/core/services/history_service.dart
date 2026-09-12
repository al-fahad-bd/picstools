import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String id;
  final String toolName;
  final String originalPath;
  final String processedPath;
  final int originalSizeBytes;
  final int processedSizeBytes;
  final DateTime timestamp;
  final String? cloudProcessedUrl;
  final String? cloudR2Key;

  bool get isSynced =>
      cloudProcessedUrl != null && cloudProcessedUrl!.isNotEmpty;

  HistoryItem({
    required this.id,
    required this.toolName,
    required this.originalPath,
    required this.processedPath,
    required this.originalSizeBytes,
    required this.processedSizeBytes,
    required this.timestamp,
    this.cloudProcessedUrl,
    this.cloudR2Key,
  });

  HistoryItem copyWith({
    String? id,
    String? toolName,
    String? originalPath,
    String? processedPath,
    int? originalSizeBytes,
    int? processedSizeBytes,
    DateTime? timestamp,
    String? cloudProcessedUrl,
    String? cloudR2Key,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      toolName: toolName ?? this.toolName,
      originalPath: originalPath ?? this.originalPath,
      processedPath: processedPath ?? this.processedPath,
      originalSizeBytes: originalSizeBytes ?? this.originalSizeBytes,
      processedSizeBytes: processedSizeBytes ?? this.processedSizeBytes,
      timestamp: timestamp ?? this.timestamp,
      cloudProcessedUrl: cloudProcessedUrl ?? this.cloudProcessedUrl,
      cloudR2Key: cloudR2Key ?? this.cloudR2Key,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'toolName': toolName,
        'originalPath': originalPath,
        'processedPath': processedPath,
        'originalSizeBytes': originalSizeBytes,
        'processedSizeBytes': processedSizeBytes,
        'timestamp': timestamp.toIso8601String(),
        'cloudProcessedUrl': cloudProcessedUrl,
        'cloudR2Key': cloudR2Key,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] as String,
        toolName: json['toolName'] as String,
        originalPath: json['originalPath'] as String,
        processedPath: json['processedPath'] as String,
        originalSizeBytes: json['originalSizeBytes'] as int,
        processedSizeBytes: json['processedSizeBytes'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        cloudProcessedUrl: json['cloudProcessedUrl'] as String?,
        cloudR2Key: json['cloudR2Key'] as String?,
      );
}

abstract class HistoryService {
  Stream<List<HistoryItem>> get historyStream;
  Future<List<HistoryItem>> getHistory();
  Future<void> addHistoryItem(HistoryItem item);
  Future<void> updateHistoryItem(HistoryItem item) async {}
  Future<void> deleteHistoryItem(String id);
  Future<void> clearHistory();
}

class HistoryServiceImpl implements HistoryService {
  static const String _key = 'picstools_history';
  final SharedPreferences _prefs;
  final Future<Directory> Function()? docsDirProvider;
  final _historyController = StreamController<List<HistoryItem>>.broadcast();

  HistoryServiceImpl(this._prefs, {this.docsDirProvider});

  Future<Directory> _getHistoryDirectory() async {
    final docsDir = docsDirProvider != null
        ? await docsDirProvider!()
        : await getApplicationDocumentsDirectory();
    final historyDir = Directory(p.join(docsDir.path, 'history_files'));
    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }
    return historyDir;
  }

  Future<void> _deletePersistedFileIfManaged(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final historyDir = await _getHistoryDirectory();
        if (p.isWithin(historyDir.path, file.path)) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('[HistoryService] Error cleaning up file $filePath: $e');
    }
  }

  @override
  Stream<List<HistoryItem>> get historyStream => _historyController.stream;

  @override
  Future<List<HistoryItem>> getHistory() async {
    final raw = _prefs.getStringList(_key) ?? [];
    final items = raw
        .map((str) => HistoryItem.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Auto-migrate any existing accessible files to permanent history storage
    bool needsSave = false;
    final migratedItems = <HistoryItem>[];

    for (final item in items) {
      try {
        final file = File(item.processedPath);
        if (await file.exists()) {
          final historyDir = await _getHistoryDirectory();
          if (!p.isWithin(historyDir.path, file.path)) {
            final ext = p.extension(item.processedPath);
            final safeExt = ext.isNotEmpty ? ext : '.png';
            final targetFileName = 'hist_${item.id}$safeExt';
            final targetFile = File(p.join(historyDir.path, targetFileName));
            await file.copy(targetFile.path);
            migratedItems.add(item.copyWith(processedPath: targetFile.path));
            needsSave = true;
            continue;
          }
        }
      } catch (_) {}
      migratedItems.add(item);
    }

    if (needsSave) {
      final jsonList = migratedItems.map((i) => jsonEncode(i.toJson())).toList();
      await _prefs.setStringList(_key, jsonList);
    }

    return migratedItems;
  }

  @override
  Future<void> addHistoryItem(HistoryItem item) async {
    HistoryItem itemToSave = item;

    try {
      final sourceFile = File(item.processedPath);
      if (await sourceFile.exists()) {
        final historyDir = await _getHistoryDirectory();

        // Only copy if not already inside historyDir
        if (!p.isWithin(historyDir.path, sourceFile.path)) {
          final ext = p.extension(item.processedPath);
          final safeExt = ext.isNotEmpty ? ext : '.png';
          final targetFileName = 'hist_${item.id}$safeExt';
          final targetFile = File(p.join(historyDir.path, targetFileName));

          await sourceFile.copy(targetFile.path);
          itemToSave = item.copyWith(processedPath: targetFile.path);
        }
      }
    } catch (e) {
      debugPrint('[HistoryService] Could not persist processed file: $e');
    }

    final list = await getHistory();
    list.insert(0, itemToSave);

    // If list exceeds 50, prune older records and their persistent files
    if (list.length > 50) {
      final toRemove = list.sublist(50);
      for (final dropped in toRemove) {
        _deletePersistedFileIfManaged(dropped.processedPath);
      }
    }

    final jsonList = list.take(50).map((i) => jsonEncode(i.toJson())).toList();
    await _prefs.setStringList(_key, jsonList);
    _historyController.add(list.take(50).toList());
  }

  @override
  Future<void> updateHistoryItem(HistoryItem updatedItem) async {
    final list = await getHistory();
    final index = list.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      list[index] = updatedItem;
      final jsonList = list.map((i) => jsonEncode(i.toJson())).toList();
      await _prefs.setStringList(_key, jsonList);
      _historyController.add(list);
    }
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    final list = await getHistory();
    final index = list.indexWhere((item) => item.id == id);
    if (index != -1) {
      final itemToDelete = list[index];
      await _deletePersistedFileIfManaged(itemToDelete.processedPath);
      list.removeAt(index);
      final jsonList = list.map((i) => jsonEncode(i.toJson())).toList();
      await _prefs.setStringList(_key, jsonList);
      _historyController.add(list);
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final historyDir = await _getHistoryDirectory();
      if (await historyDir.exists()) {
        await historyDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[HistoryService] Error clearing history files: $e');
    }
    await _prefs.remove(_key);
    _historyController.add([]);
  }

  void dispose() {
    _historyController.close();
  }
}
