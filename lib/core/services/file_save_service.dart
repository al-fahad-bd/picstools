import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

abstract class FileSaveService {
  Future<File> saveFileToPublicStorage({
    required File sourceFile,
    required String subFolder, // 'Compressed', 'Resized', 'Cropped', 'Converted', 'PDF'
  });
}

class FileSaveServiceImpl implements FileSaveService {
  @override
  Future<File> saveFileToPublicStorage({
    required File sourceFile,
    required String subFolder,
  }) async {
    Directory? targetDir;

    if (Platform.isAndroid) {
      // Save to public Downloads directory on Android
      final downloadsDir = Directory('/storage/emulated/0/Download/PicsTools/$subFolder');
      if (await downloadsDir.exists() || await _tryCreateDir(downloadsDir)) {
        targetDir = downloadsDir;
      } else {
        final extDir = await getExternalStorageDirectory();
        targetDir = Directory(p.join(extDir?.path ?? '', 'PicsTools', subFolder));
      }
    } else {
      // iOS / Desktop documents directory
      final docsDir = await getApplicationDocumentsDirectory();
      targetDir = Directory(p.join(docsDir.path, 'PicsTools', subFolder));
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final ext = p.extension(sourceFile.path);
    final fileName = 'PicsTools_${subFolder}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final destination = File(p.join(targetDir.path, fileName));

    final bytes = await sourceFile.readAsBytes();
    await destination.writeAsBytes(bytes);

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
