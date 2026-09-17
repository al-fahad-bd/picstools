import 'package:flutter_test/flutter_test.dart';
import 'package:picstools/core/services/remote_config_service.dart';

void main() {
  group('RemoteConfigService Version Comparison Tests', () {
    test('detects when current version is lower than target', () {
      expect(RemoteConfigServiceImpl.isVersionLower('1.0.0', '1.0.1'), isTrue);
      expect(RemoteConfigServiceImpl.isVersionLower('1.0.0', '1.1.0'), isTrue);
      expect(RemoteConfigServiceImpl.isVersionLower('1.0.0', '2.0.0'), isTrue);
      expect(RemoteConfigServiceImpl.isVersionLower('1.9.9', '2.0.0'), isTrue);
    });

    test('detects when current version is equal or higher than target', () {
      expect(RemoteConfigServiceImpl.isVersionLower('1.0.0', '1.0.0'), isFalse);
      expect(RemoteConfigServiceImpl.isVersionLower('1.0.1', '1.0.0'), isFalse);
      expect(RemoteConfigServiceImpl.isVersionLower('2.0.0', '1.9.9'), isFalse);
    });

    test('handles build numbers correctly', () {
      expect(RemoteConfigServiceImpl.isVersionLower('1.0.0+10', '1.0.0+11'), isTrue);
      expect(RemoteConfigServiceImpl.isVersionLower('1.0.0+11', '1.0.0+10'), isFalse);
      expect(RemoteConfigServiceImpl.isVersionLower('1.0.0+10', '1.0.1+1'), isTrue);
    });

    test('handles empty or malformed target versions gracefully', () {
      expect(RemoteConfigServiceImpl.isVersionLower('1.0.0', ''), isFalse);
      expect(RemoteConfigServiceImpl.isVersionLower('', '1.0.0'), isFalse);
    });
  });
}
