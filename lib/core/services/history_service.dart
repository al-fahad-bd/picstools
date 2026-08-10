import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String id;
  final String toolName;
  final String originalPath;
  final String processedPath;
  final int originalSizeBytes;
  final int processedSizeBytes;
  final DateTime timestamp;

  HistoryItem({
    required this.id,
    required this.toolName,
    required this.originalPath,
    required this.processedPath,
    required this.originalSizeBytes,
    required this.processedSizeBytes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'toolName': toolName,
        'originalPath': originalPath,
        'processedPath': processedPath,
        'originalSizeBytes': originalSizeBytes,
        'processedSizeBytes': processedSizeBytes,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] as String,
        toolName: json['toolName'] as String,
        originalPath: json['originalPath'] as String,
        processedPath: json['processedPath'] as String,
        originalSizeBytes: json['originalSizeBytes'] as int,
        processedSizeBytes: json['processedSizeBytes'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

abstract class HistoryService {
  Future<List<HistoryItem>> getHistory();
  Future<void> addHistoryItem(HistoryItem item);
  Future<void> clearHistory();
}

class HistoryServiceImpl implements HistoryService {
  static const String _key = 'picstools_history';
  final SharedPreferences _prefs;

  HistoryServiceImpl(this._prefs);

  @override
  Future<List<HistoryItem>> getHistory() async {
    final raw = _prefs.getStringList(_key) ?? [];
    return raw
        .map((str) => HistoryItem.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> addHistoryItem(HistoryItem item) async {
    final list = await getHistory();
    list.insert(0, item);
    final jsonList = list.take(50).map((i) => jsonEncode(i.toJson())).toList();
    await _prefs.setStringList(_key, jsonList);
  }

  @override
  Future<void> clearHistory() async {
    await _prefs.remove(_key);
  }
}
