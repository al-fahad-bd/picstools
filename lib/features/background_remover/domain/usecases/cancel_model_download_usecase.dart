import '../repositories/background_remover_repository.dart';

class CancelModelDownloadUseCase {
  final BackgroundRemoverRepository repository;

  CancelModelDownloadUseCase(this.repository);

  void call() {
    repository.cancelDownload();
  }
}
