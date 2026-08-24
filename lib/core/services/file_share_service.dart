import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import 'monetization/ad_service.dart';

abstract class FileShareService {
  Future<void> shareFiles({
    required List<XFile> files,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
    bool showAd = true,
  });
}

class FileShareServiceImpl implements FileShareService {
  final AdService _adService;

  FileShareServiceImpl(this._adService);

  @override
  Future<void> shareFiles({
    required List<XFile> files,
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
    bool showAd = true,
  }) async {
    if (files.isEmpty) return;

    if (showAd && _adService.shouldShowAds()) {
      await _adService.showInterstitialAd(
        onDismissed: () {
          Share.shareXFiles(
            files,
            text: text,
            subject: subject,
            sharePositionOrigin: sharePositionOrigin,
          );
        },
      );
    } else {
      await Share.shareXFiles(
        files,
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  }
}
