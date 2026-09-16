import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'monetization/ad_service.dart';

abstract class FileSaveService {
  Future<File> saveFileToPublicStorage({
    required File sourceFile,
    required String
    subFolder, // 'Compressed', 'Resized', 'Cropped', 'Converted', 'PDF', 'Signatures', 'Passport'
    bool showInterstitialAd = true,
  });

  Future<void> openFileOrDirectory({File? file, String? subFolder});
}

class FileSaveServiceImpl implements FileSaveService {
  final AdService _adService;

  FileSaveServiceImpl(this._adService);

  @override
  Future<File> saveFileToPublicStorage({
    required File sourceFile,
    required String subFolder,
    bool showInterstitialAd = true,
  }) async {
    // For free users, display a full-screen interstitial ad before unlocking file download
    if (showInterstitialAd && _adService.shouldShowAds()) {
      final completer = Completer<void>();
      await _adService.showInterstitialAd(
        onDismissed: () {
          if (!completer.isCompleted) completer.complete();
        },
      );
      await completer.future;
    }

    Directory? targetDir;

    // 1. On Android, use the standard public Download/PicsTools directory
    if (Platform.isAndroid) {
      final pubDownload = Directory(
        '/storage/emulated/0/Download/PicsTools/$subFolder',
      );
      if (await pubDownload.exists() || await _tryCreateDir(pubDownload)) {
        targetDir = pubDownload;
      }
    }

    // 2. Try to get downloads directory or fallback
    if (targetDir == null) {
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          targetDir = Directory(
            p.join(downloadsDir.path, 'PicsTools', subFolder),
          );
        }
      } catch (_) {}
    }

    // Fallback for Android / iOS if above is null
    if (targetDir == null) {
      if (Platform.isAndroid) {
        final extDir = await getExternalStorageDirectory();
        targetDir = Directory(
          p.join(extDir?.path ?? '', 'PicsTools', subFolder),
        );
      } else {
        final docsDir = await getApplicationDocumentsDirectory();
        targetDir = Directory(p.join(docsDir.path, 'PicsTools', subFolder));
      }
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final ext = p.extension(sourceFile.path).toLowerCase();
    final fileName =
        'PicsTools_${subFolder}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final destination = File(p.join(targetDir.path, fileName));

    final bytes = await sourceFile.readAsBytes();
    await destination.writeAsBytes(bytes);

    // 2. If file is an image, ALSO save to public Photos/Gallery under album "PicsTools"
    if (ext == '.png' || ext == '.jpg' || ext == '.jpeg' || ext == '.webp') {
      try {
        final hasAccess = await Gal.hasAccess(toAlbum: true);
        if (!hasAccess) {
          await Gal.requestAccess(toAlbum: true);
        }
        await Gal.putImage(destination.path, album: 'PicsTools');
      } catch (_) {
        // Fallback gracefully if permissions are denied or unsupported
      }
    }

    return destination;
  }

  Future<bool> _tryCreateDir(Directory dir) async {
    try {
      await dir.create(recursive: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> openFileOrDirectory({File? file, String? subFolder}) async {
    try {
      // 1. On Android: open with native viewer using FileProvider
      if (Platform.isAndroid) {
        if (file != null && await file.exists()) {
          try {
            const platform = MethodChannel('com.deltrix.picstools/native_file_viewer');
            final opened = await platform.invokeMethod<bool>('openFile', {'filePath': file.path});
            if (opened == true) {
              return;
            }
          } catch (_) {}
        }
      }

      // 2. On iOS or fallback: open photo album if image, or gal
      await Gal.open();
    } catch (_) {
      try {
        await Gal.open();
      } catch (_) {}
    }
  }
}

