import '../repositories/background_remover_repository.dart';

class DeleteModelUseCase {
  final BackgroundRemoverRepository repository;

  DeleteModelUseCase(this.repository);

  Future<bool> call() async {
    return await repository.deleteModel();
  }
}
