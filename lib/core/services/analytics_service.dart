import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

abstract class AnalyticsService {
  FirebaseAnalytics get analytics;
  FirebaseCrashlytics get crashlytics;

  Future<void> logScreenView({required String screenName, String? screenClass});
  Future<void> logToolUsed({required String toolName, Map<String, Object>? parameters});
  Future<void> logImageExported({
    required String format,
    required int fileSize,
    String? tool,
  });
  Future<void> logProViewed({required String source});
  Future<void> logPurchaseAttempt({required String productId});
  Future<void> logPurchaseSuccess({
    required String productId,
    double? price,
    String? currency,
  });
  Future<void> setUserId(String? userId);
  Future<void> setUserProperty({required String name, required String value});
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  });
  void log(String message);
  Future<void> logAdLoadFailed({
    required String adFormat,
    required int errorCode,
    required String errorMessage,
    String? domain,
  });
  Future<void> logAdShown({required String adFormat});
}

class AnalyticsServiceImpl implements AnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;

  AnalyticsServiceImpl({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  @override
  FirebaseAnalytics get analytics => _analytics;

  @override
  FirebaseCrashlytics get crashlytics => _crashlytics;

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      debugPrint('Analytics logScreenView error: $e');
    }
  }

  @override
  Future<void> logToolUsed({
    required String toolName,
    Map<String, Object>? parameters,
  }) async {
    try {
      final params = <String, Object>{'tool_name': toolName};
      if (parameters != null) {
        params.addAll(parameters);
      }
      await _analytics.logEvent(name: 'tool_used', parameters: params);
      _crashlytics.log('User opened/used tool: $toolName');
    } catch (e) {
      debugPrint('Analytics logToolUsed error: $e');
    }
  }

  @override
  Future<void> logImageExported({
    required String format,
    required int fileSize,
    String? tool,
  }) async {
    try {
      final params = <String, Object>{
        'format': format,
        'file_size_bytes': fileSize,
      };
      if (tool != null) {
        params['tool'] = tool;
      }
      await _analytics.logEvent(name: 'image_exported', parameters: params);
      _crashlytics.log('Image exported in format: $format, size: $fileSize');
    } catch (e) {
      debugPrint('Analytics logImageExported error: $e');
    }
  }

  @override
  Future<void> logProViewed({required String source}) async {
    try {
      await _analytics.logEvent(
        name: 'pro_screen_viewed',
        parameters: {'source': source},
      );
      _crashlytics.log('Pro paywall viewed from: $source');
    } catch (e) {
      debugPrint('Analytics logProViewed error: $e');
    }
  }

  @override
  Future<void> logPurchaseAttempt({required String productId}) async {
    try {
      await _analytics.logEvent(
        name: 'purchase_attempt',
        parameters: {'product_id': productId},
      );
      _crashlytics.log('Purchase attempted: $productId');
    } catch (e) {
      debugPrint('Analytics logPurchaseAttempt error: $e');
    }
  }

  @override
  Future<void> logPurchaseSuccess({
    required String productId,
    double? price,
    String? currency,
  }) async {
    try {
      await _analytics.logPurchase(
        currency: currency ?? 'USD',
        value: price,
        items: [
          AnalyticsEventItem(
            itemId: productId,
            itemName: productId,
          ),
        ],
      );
      _crashlytics.log('Purchase succeeded: $productId');
    } catch (e) {
      debugPrint('Analytics logPurchaseSuccess error: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      if (userId != null) {
        await _crashlytics.setUserIdentifier(userId);
      }
    } catch (e) {
      debugPrint('Analytics setUserId error: $e');
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      await _crashlytics.setCustomKey(name, value);
    } catch (e) {
      debugPrint('Analytics setUserProperty error: $e');
    }
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('Crashlytics recordError failed: $e');
    }
  }

  @override
  void log(String message) {
    try {
      _crashlytics.log(message);
    } catch (e) {
      debugPrint('Crashlytics log failed: $e');
    }
  }

  @override
  Future<void> logAdLoadFailed({
    required String adFormat,
    required int errorCode,
    required String errorMessage,
    String? domain,
  }) async {
    try {
      final logSummary =
          'AdMob [$adFormat] failed: code $errorCode - $errorMessage (domain: $domain)';
      debugPrint('❌ [AnalyticsService] $logSummary');
      _crashlytics.log(logSummary);

      // Record non-fatal error so it appears in Crashlytics issues table
      await _crashlytics.recordError(
        Exception('AdMob $adFormat Error $errorCode: $errorMessage'),
        null,
        reason: 'AdMob load failed for format: $adFormat (domain: $domain)',
        fatal: false,
      );

      // Also log as an Analytics event for breakdown graphs
      final params = <String, Object>{
        'ad_format': adFormat,
        'error_code': errorCode,
        'error_message': errorMessage.length > 100
            ? errorMessage.substring(0, 100)
            : errorMessage,
      };
      if (domain != null) {
        params['error_domain'] = domain;
      }

      await _analytics.logEvent(
        name: 'ad_load_failed',
        parameters: params,
      );
    } catch (e) {
      debugPrint('Failed to log ad failure: $e');
    }
  }

  @override
  Future<void> logAdShown({required String adFormat}) async {
    try {
      _crashlytics.log('AdMob [$adFormat] impression displayed successfully');
      await _analytics.logEvent(
        name: 'ad_impression_success',
        parameters: {'ad_format': adFormat},
      );
    } catch (e) {
      debugPrint('Failed to log ad shown: $e');
    }
  }
}
