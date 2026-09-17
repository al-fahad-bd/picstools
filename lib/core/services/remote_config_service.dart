import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateType {
  none,
  optional,
  force,
}

class AppUpdateInfo {
  final UpdateType type;
  final String currentVersion;
  final String targetVersion;
  final String storeUrl;
  final String title;
  final String message;

  const AppUpdateInfo({
    required this.type,
    required this.currentVersion,
    required this.targetVersion,
    required this.storeUrl,
    required this.title,
    required this.message,
  });

  bool get isForceUpdate => type == UpdateType.force;
  bool get isUpdateAvailable => type != UpdateType.none;
}

abstract class RemoteConfigService {
  Future<void> initialize();
  Future<AppUpdateInfo> checkForUpdate();
  String getString(String key);
  bool getBool(String key);
  int getInt(String key);
  double getDouble(String key);
}

class RemoteConfigServiceImpl implements RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  // Remote Config Keys
  static const String keyMinVersionAndroid = 'min_version_android';
  static const String keyLatestVersionAndroid = 'latest_version_android';
  static const String keyMinVersionIos = 'min_version_ios';
  static const String keyLatestVersionIos = 'latest_version_ios';
  static const String keyPlayStoreUrl = 'play_store_url';
  static const String keyAppStoreUrl = 'app_store_url';
  static const String keyUpdateTitle = 'update_title';
  static const String keyUpdateMessage = 'update_message';

  RemoteConfigServiceImpl({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  @override
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults(const {
        keyMinVersionAndroid: '1.0.0',
        keyLatestVersionAndroid: '1.0.0',
        keyMinVersionIos: '1.0.0',
        keyLatestVersionIos: '1.0.0',
        keyPlayStoreUrl:
            'https://play.google.com/store/apps/details?id=com.deltrix.picstools',
        keyAppStoreUrl: '',
        keyUpdateTitle: 'Update Available',
        keyUpdateMessage:
            'A new version of PicsTools is available. Please update to enjoy the latest features and improvements.',
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfig initialization error: $e');
    }
  }

  @override
  Future<AppUpdateInfo> checkForUpdate() async {
    try {
      // Try to fetch latest updates if possible
      try {
        await _remoteConfig.fetchAndActivate();
      } catch (_) {}

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;
      final fullCurrentVersion = currentBuildNumber.isNotEmpty
          ? '$currentVersion+$currentBuildNumber'
          : currentVersion;

      final isAndroid = Platform.isAndroid;
      final isIOS = Platform.isIOS;

      final minRequiredVersion = isAndroid
          ? _remoteConfig.getString(keyMinVersionAndroid)
          : isIOS
              ? _remoteConfig.getString(keyMinVersionIos)
              : '1.0.0';

      final latestAvailableVersion = isAndroid
          ? _remoteConfig.getString(keyLatestVersionAndroid)
          : isIOS
              ? _remoteConfig.getString(keyLatestVersionIos)
              : '1.0.0';

      final storeUrl = isAndroid
          ? _remoteConfig.getString(keyPlayStoreUrl)
          : isIOS
              ? _remoteConfig.getString(keyAppStoreUrl)
              : '';

      final title = _remoteConfig.getString(keyUpdateTitle);
      final message = _remoteConfig.getString(keyUpdateMessage);

      // Check 1: Force Update if below minRequiredVersion
      if (isVersionLower(fullCurrentVersion, minRequiredVersion)) {
        return AppUpdateInfo(
          type: UpdateType.force,
          currentVersion: fullCurrentVersion,
          targetVersion: minRequiredVersion,
          storeUrl: storeUrl,
          title: title.isNotEmpty ? title : 'Required Update',
          message: message.isNotEmpty
              ? message
              : 'This version of PicsTools is no longer supported. Please update to continue.',
        );
      }

      // Check 2: Optional Update if below latestAvailableVersion
      if (isVersionLower(fullCurrentVersion, latestAvailableVersion)) {
        return AppUpdateInfo(
          type: UpdateType.optional,
          currentVersion: fullCurrentVersion,
          targetVersion: latestAvailableVersion,
          storeUrl: storeUrl,
          title: title.isNotEmpty ? title : 'Update Available',
          message: message.isNotEmpty
              ? message
              : 'A new version of PicsTools is available. Would you like to update now?',
        );
      }

      // Check 3: Up to date
      return AppUpdateInfo(
        type: UpdateType.none,
        currentVersion: fullCurrentVersion,
        targetVersion: fullCurrentVersion,
        storeUrl: storeUrl,
        title: title,
        message: message,
      );
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return const AppUpdateInfo(
        type: UpdateType.none,
        currentVersion: '1.0.0',
        targetVersion: '1.0.0',
        storeUrl: '',
        title: '',
        message: '',
      );
    }
  }

  /// Compares semantic version strings e.g. "1.0.0" vs "1.0.1" or "1.0.0+10" vs "1.0.0+11"
  static bool isVersionLower(String currentVersion, String targetVersion) {
    if (targetVersion.isEmpty || currentVersion.isEmpty) return false;

    // Clean build metadata
    final cleanCurrent = currentVersion.split('+').first.trim();
    final cleanTarget = targetVersion.split('+').first.trim();

    final currentParts =
        cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final targetParts =
        cleanTarget.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = currentParts.length > targetParts.length
        ? currentParts.length
        : targetParts.length;

    for (int i = 0; i < maxLength; i++) {
      final c = i < currentParts.length ? currentParts[i] : 0;
      final t = i < targetParts.length ? targetParts[i] : 0;
      if (c < t) return true;
      if (c > t) return false;
    }

    // Compare build numbers if base versions are identical
    final currentBuild = currentVersion.contains('+')
        ? int.tryParse(currentVersion.split('+').last) ?? 0
        : 0;
    final targetBuild = targetVersion.contains('+')
        ? int.tryParse(targetVersion.split('+').last) ?? 0
        : 0;

    if (targetBuild > 0 && currentBuild > 0) {
      return currentBuild < targetBuild;
    }

    return false;
  }

  @override
  String getString(String key) => _remoteConfig.getString(key);

  @override
  bool getBool(String key) => _remoteConfig.getBool(key);

  @override
  int getInt(String key) => _remoteConfig.getInt(key);

  @override
  double getDouble(String key) => _remoteConfig.getDouble(key);
}
