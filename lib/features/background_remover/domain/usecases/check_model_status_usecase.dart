import '../entities/ai_model_info.dart';
import '../repositories/background_remover_repository.dart';

class CheckModelStatusUseCase {
  final BackgroundRemoverRepository repository;

  CheckModelStatusUseCase(this.repository);

  Future<AiModelInfo> call() async {
    return await repository.getModelInfo();
  }
}
