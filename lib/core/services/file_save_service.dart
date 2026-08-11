import 'dart:io';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

abstract class FileSaveService {
  Future<File> saveFileToPublicStorage({
    required File sourceFile,
    required String subFolder, // 'Compressed', 'Resized', 'Cropped', 'Converted', 'PDF', 'Signatures', 'Passport'
  });
}

class FileSaveServiceImpl implements FileSaveService {
  @override
  Future<File> saveFileToPublicStorage({
    required File sourceFile,
    required String subFolder,
  }) async {
    Directory? targetDir;

    // 1. Try to get public Downloads directory first across platforms
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        targetDir = Directory(p.join(downloadsDir.path, 'PicsTools', subFolder));
      }
    } catch (_) {}

    // Fallback for Android / iOS if getDownloadsDirectory is null
    if (targetDir == null) {
      if (Platform.isAndroid) {
        final pubDownload = Directory('/storage/emulated/0/Download/PicsTools/$subFolder');
        if (await pubDownload.exists() || await _tryCreateDir(pubDownload)) {
          targetDir = pubDownload;
        } else {
          final extDir = await getExternalStorageDirectory();
          targetDir = Directory(p.join(extDir?.path ?? '', 'PicsTools', subFolder));
        }
      } else {
        final docsDir = await getApplicationDocumentsDirectory();
        targetDir = Directory(p.join(docsDir.path, 'PicsTools', subFolder));
      }
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final ext = p.extension(sourceFile.path).toLowerCase();
    final fileName = 'PicsTools_${subFolder}_${DateTime.now().millisecondsSinceEpoch}$ext';
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
}
