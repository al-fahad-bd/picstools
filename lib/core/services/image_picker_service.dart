import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract class ImagePickerService {
  Future<File?> pickSingleImage({ImageSource source = ImageSource.gallery});
  Future<List<File>> pickMultipleImages();
}

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker;

  ImagePickerServiceImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<File?> pickSingleImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );
      if (file != null) {
        return File(file.path);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: 100,
      );
      return files.map((x) => File(x.path)).toList();
    } catch (_) {
      return [];
    }
  }
}
