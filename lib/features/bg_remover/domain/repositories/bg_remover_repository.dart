import 'dart:io';
import '../entities/bg_remover_params.dart';

abstract class BgRemoverRepository {
  /// Processes original image file and generates a mask, upscales mask,
  /// applies alpha channel transparency, and returns exported transparent PNG file.
  Future<File> removeBackground({
    required File imageFile,
    required BgRemoverParams params,
  });
}
