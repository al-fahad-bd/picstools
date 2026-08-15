import 'dart:io';
import '../repositories/background_remover_repository.dart';

class DownloadModelUseCase {
  final BackgroundRemoverRepository repository;

  DownloadModelUseCase(this.repository);

  Future<File> call({
    required void Function(int receivedBytes, int totalBytes, double percentage) onProgress,
  }) async {
    return await repository.downloadModel(onProgress: onProgress);
  }
}
